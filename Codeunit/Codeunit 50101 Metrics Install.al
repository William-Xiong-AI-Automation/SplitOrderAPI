codeunit 50101 metricsinstall
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        MetricsCalculator: Codeunit metricsexposurecalculator;
    begin
        MetricsCalculator.InitializeDefaults();
    end;
}
