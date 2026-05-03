codeunit 50100 metricsexposurecalculator
{
    procedure InitializeDefaults()
    begin
        UpsertMetric('openOrderExposure', 'Open Order Exposure', 'v0.5', 'SALESHEADEREXPOSURE', 'Sales Header', 'What is the total current exposure from open sales orders?', 'Status, Amount, No.', 'OPEN_ORDER_EXPOSURE', 'Open orders, open amount, average amount, and zero amount orders.', 10);
        UpsertMetric('highValueExposure', 'High-Value Exposure', 'v0.5', 'SALESHEADEREXPOSURE', 'Sales Header', 'Which open sales orders are unusually large and how much exposure do they represent?', 'No., Sell-to Customer No., Sell-to Customer Name, Amount, Location Code', 'HIGH_VALUE_EXPOSURE', 'High when high-value amount share is above the configured high threshold.', 20);
        UpsertMetric('customerConcentrationRisk', 'Customer Concentration Risk', 'v0.5', 'SALESHEADEREXPOSURE', 'Sales Header', 'Is open amount concentrated in a small number of customers?', 'Sell-to Customer No., Sell-to Customer Name, Amount', 'CUSTOMER_CONCENTRATION_RISK', 'High when top customer or top five customer share is above configured thresholds.', 30);
        UpsertMetric('locationConcentrationRisk', 'Location Concentration Risk', 'v0.5', 'SALESHEADEREXPOSURE', 'Sales Header', 'Is order amount or count concentrated in a location?', 'Location Code, Amount, No.', 'LOCATION_CONCENTRATION_RISK', 'High when top location amount share is above the configured high threshold.', 40);
        UpsertMetric('assignedUserDataRisk', 'Assigned User Data Risk', 'v0.5', 'SALESHEADEREXPOSURE', 'Sales Header', 'Do open orders have an assigned owner for workflow and escalation?', 'Assigned User ID, Amount, No.', 'ASSIGNED_USER_DATA_RISK', 'High when missing assigned user share is above the configured high threshold.', 50);
        UpsertMetric('dataCompletenessRisk', 'Data Completeness Risk', 'v0.5', 'SALESHEADEREXPOSURE', 'Sales Header', 'Is Sales Header data complete enough for later simulation?', 'No., Sell-to Customer No., Sell-to Customer Name, Location Code, Document Date, Amount, Status, Assigned User ID', 'DATA_COMPLETENESS_RISK', 'High when configured data quality thresholds are exceeded.', 60);

        UpsertTextParameter('openOrderExposure', 'statusFilter', 'Open', 'Sales Header status included in the exposure calculation.');

        UpsertDecimalParameter('highValueExposure', 'highValueThreshold', 50000, 'Minimum amount for an order to be treated as high value.');
        UpsertIntegerParameter('highValueExposure', 'topN', 50, 'Maximum number of high-value orders saved as details.');
        UpsertDecimalParameter('highValueExposure', 'mediumShareThreshold', 0.15, 'Medium risk threshold for high-value amount share.');
        UpsertDecimalParameter('highValueExposure', 'highShareThreshold', 0.30, 'High risk threshold for high-value amount share.');

        UpsertDecimalParameter('customerConcentrationRisk', 'top1MediumShareThreshold', 0.15, 'Medium risk threshold for top customer share.');
        UpsertDecimalParameter('customerConcentrationRisk', 'top1HighShareThreshold', 0.25, 'High risk threshold for top customer share.');
        UpsertDecimalParameter('customerConcentrationRisk', 'top5MediumShareThreshold', 0.35, 'Medium risk threshold for top five customer share.');
        UpsertDecimalParameter('customerConcentrationRisk', 'top5HighShareThreshold', 0.50, 'High risk threshold for top five customer share.');
        UpsertIntegerParameter('customerConcentrationRisk', 'topN', 10, 'Maximum number of customers saved as details.');

        UpsertDecimalParameter('locationConcentrationRisk', 'mediumShareThreshold', 0.50, 'Medium risk threshold for top location amount share.');
        UpsertDecimalParameter('locationConcentrationRisk', 'highShareThreshold', 0.70, 'High risk threshold for top location amount share.');
        UpsertIntegerParameter('locationConcentrationRisk', 'topN', 10, 'Maximum number of locations saved as details.');

        UpsertDecimalParameter('assignedUserDataRisk', 'mediumMissingShareThreshold', 0.20, 'Medium risk threshold for missing assigned user share.');
        UpsertDecimalParameter('assignedUserDataRisk', 'highMissingShareThreshold', 0.50, 'High risk threshold for missing assigned user share.');

        UpsertDecimalParameter('dataCompletenessRisk', 'sameDocumentDateHighRatio', 0.90, 'High risk threshold when too many orders share the same document date.');
        UpsertDecimalParameter('dataCompletenessRisk', 'zeroAmountMediumShareThreshold', 0.10, 'Medium risk threshold for zero amount order share.');
        UpsertDecimalParameter('dataCompletenessRisk', 'zeroAmountHighShareThreshold', 0.25, 'High risk threshold for zero amount order share.');
        UpsertDecimalParameter('dataCompletenessRisk', 'missingLocationMediumShareThreshold', 0.10, 'Medium risk threshold for missing location share.');
        UpsertDecimalParameter('dataCompletenessRisk', 'missingLocationHighShareThreshold', 0.25, 'High risk threshold for missing location share.');
    end;

    procedure CalculateSalesHeaderExposure(): Integer
    var
        SalesHeader: Record "Sales Header";
        Snapshot: Record metricssnapshot;
        TempHighValueOrders: Record metricssnapshotdetail temporary;
        TempCustomers: Record metricssnapshotdetail temporary;
        TempLocations: Record metricssnapshotdetail temporary;
        TempDocumentDates: Record metricssnapshotdetail temporary;
        Amount: Decimal;
        HighValueAmount: Decimal;
        HighValueOrderCount: Integer;
        MissingAssignedUserAmount: Decimal;
        MissingAssignedUserCount: Integer;
        MissingCustomerNameCount: Integer;
        MissingCustomerNoCount: Integer;
        MissingLocationCount: Integer;
        OpenAmount: Decimal;
        OpenOrderCount: Integer;
        StatusFilter: Text[50];
        TempLineNo: Integer;
        ZeroAmountOrders: Integer;
    begin
        InitializeDefaults();

        StatusFilter := CopyStr(GetTextParameter('openOrderExposure', 'statusFilter', 'Open'), 1, MaxStrLen(StatusFilter));

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if UpperCase(StatusFilter) = 'OPEN' then
            SalesHeader.SetRange(Status, SalesHeader.Status::Open);

        if SalesHeader.FindSet() then
            repeat
                SalesHeader.CalcFields(Amount);
                Amount := SalesHeader.Amount;
                OpenOrderCount += 1;
                OpenAmount += Amount;

                if Amount = 0 then
                    ZeroAmountOrders += 1;

                if SalesHeader."Assigned User ID" = '' then begin
                    MissingAssignedUserCount += 1;
                    MissingAssignedUserAmount += Amount;
                end;

                if SalesHeader."Sell-to Customer No." = '' then
                    MissingCustomerNoCount += 1;

                if SalesHeader."Sell-to Customer Name" = '' then
                    MissingCustomerNameCount += 1;

                if SalesHeader."Location Code" = '' then
                    MissingLocationCount += 1;

                AddCustomerAmount(TempCustomers, SalesHeader, Amount, TempLineNo);
                AddLocationAmount(TempLocations, SalesHeader, Amount, TempLineNo);
                AddDocumentDateCount(TempDocumentDates, SalesHeader, TempLineNo);

                if Amount >= GetDecimalParameter('highValueExposure', 'highValueThreshold', 50000) then begin
                    HighValueOrderCount += 1;
                    HighValueAmount += Amount;
                    AddHighValueOrder(TempHighValueOrders, SalesHeader, Amount, TempLineNo);
                end;
            until SalesHeader.Next() = 0;

        Snapshot.Init();
        Snapshot."Context Type" := 'SH_EXPOSURE_V0_5';
        Snapshot."As Of DateTime" := CurrentDateTime();
        Snapshot."Source Table" := 'Sales Header';
        Snapshot."Status Filter" := StatusFilter;
        Snapshot."Open Order Count" := OpenOrderCount;
        Snapshot."Open Amount" := OpenAmount;
        Snapshot.Insert(true);

        SaveMetricLinesAndDetails(Snapshot."Snapshot No.", OpenOrderCount, OpenAmount, ZeroAmountOrders, HighValueOrderCount, HighValueAmount, MissingAssignedUserCount, MissingAssignedUserAmount, MissingCustomerNoCount, MissingCustomerNameCount, MissingLocationCount, TempHighValueOrders, TempCustomers, TempLocations, TempDocumentDates);

        exit(Snapshot."Snapshot No.");
    end;

    local procedure SaveMetricLinesAndDetails(SnapshotNo: Integer; OpenOrderCount: Integer; OpenAmount: Decimal; ZeroAmountOrders: Integer; HighValueOrderCount: Integer; HighValueAmount: Decimal; MissingAssignedUserCount: Integer; MissingAssignedUserAmount: Decimal; MissingCustomerNoCount: Integer; MissingCustomerNameCount: Integer; MissingLocationCount: Integer; var TempHighValueOrders: Record metricssnapshotdetail temporary; var TempCustomers: Record metricssnapshotdetail temporary; var TempLocations: Record metricssnapshotdetail temporary; var TempDocumentDates: Record metricssnapshotdetail temporary)
    var
        DetailLineNo: Integer;
        LineNo: Integer;
        Top1CustomerShare: Decimal;
        Top5CustomerShare: Decimal;
        Top10CustomerShare: Decimal;
        TopDateCount: Integer;
        TopLocationAmountShare: Decimal;
        TopLocationCode: Code[10];
        TopLocationOrderShare: Decimal;
    begin
        if IsMetricActive('openOrderExposure') then
            AddSnapshotLine(SnapshotNo, LineNo, 'openOrderExposure', '', OpenAmount, SafeDivide(OpenAmount, OpenOrderCount), 0, OpenOrderCount, ZeroAmountOrders, StrSubstNo('Open orders %1, open amount %2, average order amount %3, zero amount orders %4.', OpenOrderCount, OpenAmount, SafeDivide(OpenAmount, OpenOrderCount), ZeroAmountOrders), 'statusFilter=' + GetTextParameter('openOrderExposure', 'statusFilter', 'Open'));

        if IsMetricActive('highValueExposure') then begin
            AddSnapshotLine(SnapshotNo, LineNo, 'highValueExposure', RiskFromShare(SafeDivide(HighValueAmount, OpenAmount), GetDecimalParameter('highValueExposure', 'mediumShareThreshold', 0.15), GetDecimalParameter('highValueExposure', 'highShareThreshold', 0.30)), HighValueAmount, SafeDivide(HighValueAmount, OpenAmount), GetDecimalParameter('highValueExposure', 'highValueThreshold', 50000), HighValueOrderCount, 0, StrSubstNo('High-value orders %1, amount %2, share %3.', HighValueOrderCount, HighValueAmount, SafeDivide(HighValueAmount, OpenAmount)), StrSubstNo('threshold=%1; mediumShare=%2; highShare=%3', GetDecimalParameter('highValueExposure', 'highValueThreshold', 50000), GetDecimalParameter('highValueExposure', 'mediumShareThreshold', 0.15), GetDecimalParameter('highValueExposure', 'highShareThreshold', 0.30)));
            CopyTopDetails(SnapshotNo, DetailLineNo, TempHighValueOrders, 'highValueExposure', 'TOP_HIGH_VALUE_ORDER', GetIntegerParameter('highValueExposure', 'topN', 50), OpenAmount, OpenOrderCount);
        end;

        if IsMetricActive('customerConcentrationRisk') then begin
            GetCustomerShares(TempCustomers, OpenAmount, Top1CustomerShare, Top5CustomerShare, Top10CustomerShare);
            AddSnapshotLine(SnapshotNo, LineNo, 'customerConcentrationRisk', CustomerRiskLevel(Top1CustomerShare, Top5CustomerShare), Top1CustomerShare, Top5CustomerShare, Top10CustomerShare, 0, 0, StrSubstNo('Top 1 customer share %1, top 5 share %2, top 10 share %3.', Top1CustomerShare, Top5CustomerShare, Top10CustomerShare), StrSubstNo('top1Medium=%1; top1High=%2; top5Medium=%3; top5High=%4', GetDecimalParameter('customerConcentrationRisk', 'top1MediumShareThreshold', 0.15), GetDecimalParameter('customerConcentrationRisk', 'top1HighShareThreshold', 0.25), GetDecimalParameter('customerConcentrationRisk', 'top5MediumShareThreshold', 0.35), GetDecimalParameter('customerConcentrationRisk', 'top5HighShareThreshold', 0.50)));
            CopyTopDetails(SnapshotNo, DetailLineNo, TempCustomers, 'customerConcentrationRisk', 'TOP_CUSTOMER', GetIntegerParameter('customerConcentrationRisk', 'topN', 10), OpenAmount, OpenOrderCount);
        end;

        if IsMetricActive('locationConcentrationRisk') then begin
            GetLocationShares(TempLocations, OpenAmount, OpenOrderCount, TopLocationCode, TopLocationAmountShare, TopLocationOrderShare);
            AddSnapshotLine(SnapshotNo, LineNo, 'locationConcentrationRisk', RiskFromShare(TopLocationAmountShare, GetDecimalParameter('locationConcentrationRisk', 'mediumShareThreshold', 0.50), GetDecimalParameter('locationConcentrationRisk', 'highShareThreshold', 0.70)), TopLocationAmountShare, TopLocationOrderShare, 0, 0, 0, StrSubstNo('Top location %1 amount share %2, order share %3.', TopLocationCode, TopLocationAmountShare, TopLocationOrderShare), StrSubstNo('mediumShare=%1; highShare=%2', GetDecimalParameter('locationConcentrationRisk', 'mediumShareThreshold', 0.50), GetDecimalParameter('locationConcentrationRisk', 'highShareThreshold', 0.70)));
            CopyTopDetails(SnapshotNo, DetailLineNo, TempLocations, 'locationConcentrationRisk', 'TOP_LOCATION', GetIntegerParameter('locationConcentrationRisk', 'topN', 10), OpenAmount, OpenOrderCount);
        end;

        if IsMetricActive('assignedUserDataRisk') then
            AddSnapshotLine(SnapshotNo, LineNo, 'assignedUserDataRisk', RiskFromShare(SafeDivide(MissingAssignedUserCount, OpenOrderCount), GetDecimalParameter('assignedUserDataRisk', 'mediumMissingShareThreshold', 0.20), GetDecimalParameter('assignedUserDataRisk', 'highMissingShareThreshold', 0.50)), MissingAssignedUserAmount, SafeDivide(MissingAssignedUserCount, OpenOrderCount), 0, MissingAssignedUserCount, 0, StrSubstNo('Missing assigned user count %1, amount %2, share %3.', MissingAssignedUserCount, MissingAssignedUserAmount, SafeDivide(MissingAssignedUserCount, OpenOrderCount)), StrSubstNo('mediumMissingShare=%1; highMissingShare=%2', GetDecimalParameter('assignedUserDataRisk', 'mediumMissingShareThreshold', 0.20), GetDecimalParameter('assignedUserDataRisk', 'highMissingShareThreshold', 0.50)));

        if IsMetricActive('dataCompletenessRisk') then begin
            TopDateCount := GetTopDocumentDateCount(TempDocumentDates);
            AddSnapshotLine(SnapshotNo, LineNo, 'dataCompletenessRisk', DataCompletenessRiskLevel(OpenOrderCount, ZeroAmountOrders, MissingLocationCount, TopDateCount), SafeDivide(ZeroAmountOrders, OpenOrderCount), SafeDivide(MissingLocationCount, OpenOrderCount), SafeDivide(TopDateCount, OpenOrderCount), MissingCustomerNoCount, MissingCustomerNameCount, StrSubstNo('Missing customer no %1, missing customer name %2, missing location %3, zero amount %4, same document date ratio %5.', MissingCustomerNoCount, MissingCustomerNameCount, MissingLocationCount, ZeroAmountOrders, SafeDivide(TopDateCount, OpenOrderCount)), StrSubstNo('sameDateHigh=%1; zeroAmountMedium=%2; zeroAmountHigh=%3; missingLocationMedium=%4; missingLocationHigh=%5', GetDecimalParameter('dataCompletenessRisk', 'sameDocumentDateHighRatio', 0.90), GetDecimalParameter('dataCompletenessRisk', 'zeroAmountMediumShareThreshold', 0.10), GetDecimalParameter('dataCompletenessRisk', 'zeroAmountHighShareThreshold', 0.25), GetDecimalParameter('dataCompletenessRisk', 'missingLocationMediumShareThreshold', 0.10), GetDecimalParameter('dataCompletenessRisk', 'missingLocationHighShareThreshold', 0.25)));
            AddDataQualityDetails(SnapshotNo, DetailLineNo, OpenOrderCount, MissingCustomerNoCount, MissingCustomerNameCount, MissingLocationCount, ZeroAmountOrders, TopDateCount);
        end;
    end;

    local procedure AddSnapshotLine(SnapshotNo: Integer; var LineNo: Integer; MetricCode: Code[50]; RiskLevel: Code[20]; DecimalValue1: Decimal; DecimalValue2: Decimal; DecimalValue3: Decimal; IntegerValue1: Integer; IntegerValue2: Integer; TextSummary: Text[500]; RuleUsed: Text[500])
    var
        Metric: Record metrics;
        SnapshotLine: Record metricssnapshotline;
    begin
        LineNo += 10000;
        SnapshotLine.Init();
        SnapshotLine."Snapshot No." := SnapshotNo;
        SnapshotLine."Line No." := LineNo;
        SnapshotLine."Metric Code" := MetricCode;
        if Metric.Get(MetricCode) then
            SnapshotLine."Metric Name" := Metric."Metric Name";
        SnapshotLine."Risk Level" := RiskLevel;
        SnapshotLine."Decimal Value 1" := DecimalValue1;
        SnapshotLine."Decimal Value 2" := DecimalValue2;
        SnapshotLine."Decimal Value 3" := DecimalValue3;
        SnapshotLine."Integer Value 1" := IntegerValue1;
        SnapshotLine."Integer Value 2" := IntegerValue2;
        SnapshotLine."Text Summary" := TextSummary;
        SnapshotLine."Rule Used" := RuleUsed;
        SnapshotLine.Insert();
    end;

    local procedure AddHighValueOrder(var TempDetails: Record metricssnapshotdetail temporary; SalesHeader: Record "Sales Header"; Amount: Decimal; var TempLineNo: Integer)
    begin
        TempLineNo += 1;
        TempDetails.Init();
        TempDetails."Snapshot No." := 0;
        TempDetails."Line No." := TempLineNo;
        TempDetails."Metric Code" := 'highValueExposure';
        TempDetails."Detail Type" := 'TOP_HIGH_VALUE_ORDER';
        TempDetails."Source No." := SalesHeader."No.";
        TempDetails."Source Name" := SalesHeader."Sell-to Customer Name";
        TempDetails."Customer No." := SalesHeader."Sell-to Customer No.";
        TempDetails."Customer Name" := SalesHeader."Sell-to Customer Name";
        TempDetails."Location Code" := SalesHeader."Location Code";
        TempDetails.Amount := Amount;
        TempDetails."Order Count" := 1;
        TempDetails.Insert();
    end;

    local procedure AddCustomerAmount(var TempDetails: Record metricssnapshotdetail temporary; SalesHeader: Record "Sales Header"; Amount: Decimal; var TempLineNo: Integer)
    begin
        TempDetails.Reset();
        TempDetails.SetRange("Metric Code", 'customerConcentrationRisk');
        TempDetails.SetRange("Detail Type", 'TOP_CUSTOMER');
        TempDetails.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        if TempDetails.FindFirst() then begin
            TempDetails.Amount += Amount;
            TempDetails."Order Count" += 1;
            TempDetails.Modify();
            exit;
        end;

        TempLineNo += 1;
        TempDetails.Init();
        TempDetails."Snapshot No." := 0;
        TempDetails."Line No." := TempLineNo;
        TempDetails."Metric Code" := 'customerConcentrationRisk';
        TempDetails."Detail Type" := 'TOP_CUSTOMER';
        TempDetails."Source No." := SalesHeader."Sell-to Customer No.";
        TempDetails."Source Name" := SalesHeader."Sell-to Customer Name";
        TempDetails."Customer No." := SalesHeader."Sell-to Customer No.";
        TempDetails."Customer Name" := SalesHeader."Sell-to Customer Name";
        TempDetails.Amount := Amount;
        TempDetails."Order Count" := 1;
        TempDetails.Insert();
    end;

    local procedure AddLocationAmount(var TempDetails: Record metricssnapshotdetail temporary; SalesHeader: Record "Sales Header"; Amount: Decimal; var TempLineNo: Integer)
    begin
        TempDetails.Reset();
        TempDetails.SetRange("Metric Code", 'locationConcentrationRisk');
        TempDetails.SetRange("Detail Type", 'TOP_LOCATION');
        TempDetails.SetRange("Location Code", SalesHeader."Location Code");
        if TempDetails.FindFirst() then begin
            TempDetails.Amount += Amount;
            TempDetails."Order Count" += 1;
            TempDetails.Modify();
            exit;
        end;

        TempLineNo += 1;
        TempDetails.Init();
        TempDetails."Snapshot No." := 0;
        TempDetails."Line No." := TempLineNo;
        TempDetails."Metric Code" := 'locationConcentrationRisk';
        TempDetails."Detail Type" := 'TOP_LOCATION';
        TempDetails."Source No." := SalesHeader."Location Code";
        TempDetails."Source Name" := SalesHeader."Location Code";
        TempDetails."Location Code" := SalesHeader."Location Code";
        TempDetails.Amount := Amount;
        TempDetails."Order Count" := 1;
        TempDetails.Insert();
    end;

    local procedure AddDocumentDateCount(var TempDetails: Record metricssnapshotdetail temporary; SalesHeader: Record "Sales Header"; var TempLineNo: Integer)
    var
        DocumentDateKey: Code[50];
    begin
        DocumentDateKey := CopyStr(Format(SalesHeader."Document Date", 0, 9), 1, MaxStrLen(DocumentDateKey));
        TempDetails.Reset();
        TempDetails.SetRange("Metric Code", 'dataCompletenessRisk');
        TempDetails.SetRange("Detail Type", 'DOCUMENT_DATE');
        TempDetails.SetRange("Source No.", DocumentDateKey);
        if TempDetails.FindFirst() then begin
            TempDetails."Order Count" += 1;
            TempDetails.Modify();
            exit;
        end;

        TempLineNo += 1;
        TempDetails.Init();
        TempDetails."Snapshot No." := 0;
        TempDetails."Line No." := TempLineNo;
        TempDetails."Metric Code" := 'dataCompletenessRisk';
        TempDetails."Detail Type" := 'DOCUMENT_DATE';
        TempDetails."Source No." := DocumentDateKey;
        TempDetails."Order Count" := 1;
        TempDetails.Insert();
    end;

    local procedure CopyTopDetails(SnapshotNo: Integer; var DetailLineNo: Integer; var TempDetails: Record metricssnapshotdetail temporary; MetricCode: Code[50]; DetailType: Code[50]; TopN: Integer; TotalAmount: Decimal; TotalOrders: Integer)
    var
        Rank: Integer;
        SnapshotDetail: Record metricssnapshotdetail;
    begin
        if TopN <= 0 then
            exit;

        TempDetails.Reset();
        TempDetails.SetCurrentKey("Metric Code", "Detail Type", Amount);
        TempDetails.SetRange("Metric Code", MetricCode);
        TempDetails.SetRange("Detail Type", DetailType);
        TempDetails.Ascending(false);
        if TempDetails.FindSet() then
            repeat
                Rank += 1;
                DetailLineNo += 10000;
                SnapshotDetail.Init();
                SnapshotDetail.TransferFields(TempDetails, false);
                SnapshotDetail."Snapshot No." := SnapshotNo;
                SnapshotDetail."Line No." := DetailLineNo;
                SnapshotDetail.Rank := Rank;
                SnapshotDetail.Share := SafeDivide(TempDetails.Amount, TotalAmount);
                if DetailType = 'TOP_LOCATION' then
                    SnapshotDetail.Note := CopyStr(StrSubstNo('Order share %1', SafeDivide(TempDetails."Order Count", TotalOrders)), 1, MaxStrLen(SnapshotDetail.Note));
                SnapshotDetail.Insert();
            until (TempDetails.Next() = 0) or (Rank >= TopN);
    end;

    local procedure AddDataQualityDetails(SnapshotNo: Integer; var DetailLineNo: Integer; OpenOrderCount: Integer; MissingCustomerNoCount: Integer; MissingCustomerNameCount: Integer; MissingLocationCount: Integer; ZeroAmountOrders: Integer; TopDateCount: Integer)
    begin
        AddDataQualityDetail(SnapshotNo, DetailLineNo, 'Missing Customer No.', MissingCustomerNoCount, SafeDivide(MissingCustomerNoCount, OpenOrderCount));
        AddDataQualityDetail(SnapshotNo, DetailLineNo, 'Missing Customer Name', MissingCustomerNameCount, SafeDivide(MissingCustomerNameCount, OpenOrderCount));
        AddDataQualityDetail(SnapshotNo, DetailLineNo, 'Missing Location Code', MissingLocationCount, SafeDivide(MissingLocationCount, OpenOrderCount));
        AddDataQualityDetail(SnapshotNo, DetailLineNo, 'Zero Amount Orders', ZeroAmountOrders, SafeDivide(ZeroAmountOrders, OpenOrderCount));
        AddDataQualityDetail(SnapshotNo, DetailLineNo, 'Same Document Date Ratio', TopDateCount, SafeDivide(TopDateCount, OpenOrderCount));
    end;

    local procedure AddDataQualityDetail(SnapshotNo: Integer; var DetailLineNo: Integer; Note: Text[500]; CountValue: Integer; ShareValue: Decimal)
    var
        SnapshotDetail: Record metricssnapshotdetail;
    begin
        DetailLineNo += 10000;
        SnapshotDetail.Init();
        SnapshotDetail."Snapshot No." := SnapshotNo;
        SnapshotDetail."Line No." := DetailLineNo;
        SnapshotDetail."Metric Code" := 'dataCompletenessRisk';
        SnapshotDetail."Detail Type" := 'DATA_QUALITY';
        SnapshotDetail.Rank := DetailLineNo div 10000;
        SnapshotDetail."Order Count" := CountValue;
        SnapshotDetail.Share := ShareValue;
        SnapshotDetail.Note := Note;
        SnapshotDetail.Insert();
    end;

    local procedure GetCustomerShares(var TempCustomers: Record metricssnapshotdetail temporary; TotalAmount: Decimal; var Top1Share: Decimal; var Top5Share: Decimal; var Top10Share: Decimal)
    var
        Rank: Integer;
        TopAmount: Decimal;
    begin
        TempCustomers.Reset();
        TempCustomers.SetCurrentKey("Metric Code", "Detail Type", Amount);
        TempCustomers.SetRange("Metric Code", 'customerConcentrationRisk');
        TempCustomers.SetRange("Detail Type", 'TOP_CUSTOMER');
        TempCustomers.Ascending(false);
        if TempCustomers.FindSet() then
            repeat
                Rank += 1;
                TopAmount += TempCustomers.Amount;
                if Rank = 1 then
                    Top1Share := SafeDivide(TempCustomers.Amount, TotalAmount);
                if Rank = 5 then
                    Top5Share := SafeDivide(TopAmount, TotalAmount);
                if Rank = 10 then
                    Top10Share := SafeDivide(TopAmount, TotalAmount);
            until (TempCustomers.Next() = 0) or (Rank >= 10);

        if (Rank > 0) and (Rank < 5) then
            Top5Share := SafeDivide(TopAmount, TotalAmount);

        if (Rank > 0) and (Rank < 10) then
            Top10Share := SafeDivide(TopAmount, TotalAmount);
    end;

    local procedure GetLocationShares(var TempLocations: Record metricssnapshotdetail temporary; TotalAmount: Decimal; TotalOrders: Integer; var TopLocationCode: Code[10]; var TopAmountShare: Decimal; var TopOrderShare: Decimal)
    begin
        TempLocations.Reset();
        TempLocations.SetCurrentKey("Metric Code", "Detail Type", Amount);
        TempLocations.SetRange("Metric Code", 'locationConcentrationRisk');
        TempLocations.SetRange("Detail Type", 'TOP_LOCATION');
        TempLocations.Ascending(false);
        if TempLocations.FindFirst() then begin
            TopLocationCode := TempLocations."Location Code";
            TopAmountShare := SafeDivide(TempLocations.Amount, TotalAmount);
            TopOrderShare := SafeDivide(TempLocations."Order Count", TotalOrders);
        end;
    end;

    local procedure GetTopDocumentDateCount(var TempDocumentDates: Record metricssnapshotdetail temporary): Integer
    begin
        TempDocumentDates.Reset();
        TempDocumentDates.SetCurrentKey("Metric Code", "Detail Type", "Order Count");
        TempDocumentDates.SetRange("Metric Code", 'dataCompletenessRisk');
        TempDocumentDates.SetRange("Detail Type", 'DOCUMENT_DATE');
        TempDocumentDates.Ascending(false);
        if TempDocumentDates.FindFirst() then
            exit(TempDocumentDates."Order Count");
    end;

    local procedure CustomerRiskLevel(Top1Share: Decimal; Top5Share: Decimal): Code[20]
    begin
        if (Top1Share > GetDecimalParameter('customerConcentrationRisk', 'top1HighShareThreshold', 0.25)) or
           (Top5Share > GetDecimalParameter('customerConcentrationRisk', 'top5HighShareThreshold', 0.50))
        then
            exit('HIGH');

        if (Top1Share > GetDecimalParameter('customerConcentrationRisk', 'top1MediumShareThreshold', 0.15)) or
           (Top5Share > GetDecimalParameter('customerConcentrationRisk', 'top5MediumShareThreshold', 0.35))
        then
            exit('MEDIUM');

        exit('LOW');
    end;

    local procedure DataCompletenessRiskLevel(OpenOrderCount: Integer; ZeroAmountOrders: Integer; MissingLocationCount: Integer; TopDateCount: Integer): Code[20]
    var
        MissingLocationShare: Decimal;
        SameDocumentDateRatio: Decimal;
        ZeroAmountShare: Decimal;
    begin
        ZeroAmountShare := SafeDivide(ZeroAmountOrders, OpenOrderCount);
        MissingLocationShare := SafeDivide(MissingLocationCount, OpenOrderCount);
        SameDocumentDateRatio := SafeDivide(TopDateCount, OpenOrderCount);

        if (SameDocumentDateRatio > GetDecimalParameter('dataCompletenessRisk', 'sameDocumentDateHighRatio', 0.90)) or
           (ZeroAmountShare > GetDecimalParameter('dataCompletenessRisk', 'zeroAmountHighShareThreshold', 0.25)) or
           (MissingLocationShare > GetDecimalParameter('dataCompletenessRisk', 'missingLocationHighShareThreshold', 0.25))
        then
            exit('HIGH');

        if (ZeroAmountShare > GetDecimalParameter('dataCompletenessRisk', 'zeroAmountMediumShareThreshold', 0.10)) or
           (MissingLocationShare > GetDecimalParameter('dataCompletenessRisk', 'missingLocationMediumShareThreshold', 0.10))
        then
            exit('MEDIUM');

        exit('LOW');
    end;

    local procedure RiskFromShare(Share: Decimal; MediumThreshold: Decimal; HighThreshold: Decimal): Code[20]
    begin
        if Share > HighThreshold then
            exit('HIGH');

        if Share > MediumThreshold then
            exit('MEDIUM');

        exit('LOW');
    end;

    local procedure SafeDivide(Numerator: Decimal; Denominator: Decimal): Decimal
    begin
        if Denominator = 0 then
            exit(0);

        exit(Numerator / Denominator);
    end;

    local procedure IsMetricActive(MetricCode: Code[50]): Boolean
    var
        Metric: Record metrics;
    begin
        if not Metric.Get(MetricCode) then
            exit(false);

        exit(Metric.Active);
    end;

    local procedure GetDecimalParameter(MetricCode: Code[50]; ParameterCode: Code[50]; DefaultValue: Decimal): Decimal
    var
        Parameter: Record metricsparameter;
    begin
        if Parameter.Get(MetricCode, ParameterCode) then
            if Parameter.Active then
                exit(Parameter."Decimal Value");

        exit(DefaultValue);
    end;

    local procedure GetIntegerParameter(MetricCode: Code[50]; ParameterCode: Code[50]; DefaultValue: Integer): Integer
    var
        Parameter: Record metricsparameter;
    begin
        if Parameter.Get(MetricCode, ParameterCode) then
            if Parameter.Active then
                exit(Parameter."Integer Value");

        exit(DefaultValue);
    end;

    local procedure GetTextParameter(MetricCode: Code[50]; ParameterCode: Code[50]; DefaultValue: Text): Text
    var
        Parameter: Record metricsparameter;
    begin
        if Parameter.Get(MetricCode, ParameterCode) then
            if Parameter.Active then
                exit(Parameter."Text Value");

        exit(DefaultValue);
    end;

    local procedure UpsertMetric(MetricCode: Code[50]; MetricName: Text[100]; MetricVersion: Code[20]; Category: Code[50]; SourceTable: Text[100]; BusinessQuestion: Text[250]; InputFields: Text[500]; CalculationType: Code[50]; RiskRuleSummary: Text[500]; SortOrder: Integer)
    var
        Metric: Record metrics;
        MetricExists: Boolean;
    begin
        MetricExists := Metric.Get(MetricCode);
        if not MetricExists then begin
            Metric.Init();
            Metric."Metric Code" := MetricCode;
            Metric.Active := true;
        end;

        Metric."Metric Name" := MetricName;
        Metric."Metric Version" := MetricVersion;
        Metric.Category := Category;
        Metric."Source Table" := SourceTable;
        Metric."Business Question" := BusinessQuestion;
        Metric."Input Fields" := InputFields;
        Metric."Calculation Type" := CalculationType;
        Metric."Risk Rule Summary" := RiskRuleSummary;
        Metric."Sort Order" := SortOrder;

        if MetricExists then
            Metric.Modify(true);
        if not MetricExists then
            Metric.Insert(true);
    end;

    local procedure UpsertDecimalParameter(MetricCode: Code[50]; ParameterCode: Code[50]; DefaultValue: Decimal; Description: Text[250])
    var
        Parameter: Record metricsparameter;
    begin
        if Parameter.Get(MetricCode, ParameterCode) then
            exit;

        Parameter.Init();
        Parameter."Metric Code" := MetricCode;
        Parameter."Parameter Code" := ParameterCode;
        Parameter."Parameter Type" := Parameter."Parameter Type"::DecimalValue;
        Parameter."Decimal Value" := DefaultValue;
        Parameter.Description := Description;
        Parameter.Active := true;
        Parameter.Insert(true);
    end;

    local procedure UpsertIntegerParameter(MetricCode: Code[50]; ParameterCode: Code[50]; DefaultValue: Integer; Description: Text[250])
    var
        Parameter: Record metricsparameter;
    begin
        if Parameter.Get(MetricCode, ParameterCode) then
            exit;

        Parameter.Init();
        Parameter."Metric Code" := MetricCode;
        Parameter."Parameter Code" := ParameterCode;
        Parameter."Parameter Type" := Parameter."Parameter Type"::IntegerValue;
        Parameter."Integer Value" := DefaultValue;
        Parameter.Description := Description;
        Parameter.Active := true;
        Parameter.Insert(true);
    end;

    local procedure UpsertTextParameter(MetricCode: Code[50]; ParameterCode: Code[50]; DefaultValue: Text[100]; Description: Text[250])
    var
        Parameter: Record metricsparameter;
    begin
        if Parameter.Get(MetricCode, ParameterCode) then
            exit;

        Parameter.Init();
        Parameter."Metric Code" := MetricCode;
        Parameter."Parameter Code" := ParameterCode;
        Parameter."Parameter Type" := Parameter."Parameter Type"::TextValue;
        Parameter."Text Value" := DefaultValue;
        Parameter.Description := Description;
        Parameter.Active := true;
        Parameter.Insert(true);
    end;
}
