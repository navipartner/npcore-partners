page 6014439 "NPR Retail Tools"
{
    Caption = 'Retail Tools';
    UsageCategory = Administration;
    ApplicationArea = All;
    actions
    {
        area(Processing)
        {
            action(NPRMigrateAuditRollToPOSEntry)
            {
                Caption = 'Migrate Audit Roll to POS Entry';
                Image = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    RetailDataModelUpgrade: Codeunit "NPR UPG RetDataMod AR Upgr.";
                begin
                    if Confirm('Start data migration?', false) then
                        RetailDataModelUpgrade.Run();
                end;
            }
        }
    }
}