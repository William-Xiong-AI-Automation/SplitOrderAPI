
//API Page：POST 触发计算并返回结果
page 52102 "Price Calc API"
{
    PageType = API;
    SourceTable = "Price Calc Request";
    APIPublisher = 'luminys';
    APIGroup = 'pricing';
    APIVersion = 'v1.0';
    EntityName = 'priceCalc';
    EntitySetName = 'priceCalcs';

    ODataKeyFields = ID;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.ID) { Caption = 'id'; Editable = false; }

                field(customerNo; Rec."Customer No.") { }
                field(itemNo; Rec."Item No.") { }
                field(quantity; Rec.Quantity) { }
                field(currencyCode; Rec."Currency Code") { }

                field(unitPrice; Rec."Unit Price") { Editable = false; }
                field(lineDiscountPct; Rec."Line Discount %") { Editable = false; }
                field(lineAmount; Rec."Line Amount") { Editable = false; }
                field(amountIncludingVAT; Rec."Amount Including VAT") { Editable = false; }
            }
        }
    }

    // ✅ 删除 trigger OnAfterInsertRecord()（API Page 不支持）
}
