page 6184518 "NPR License Pools"
{
    Caption = 'NPR License Pools';
    PageType = ListPart;
    SourceTable = "NPR License Pool";
    UsageCategory = None;
    ApplicationArea = NPRRetail;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                }
                field(Module; Rec.Module)
                {
                }
                field("License Term"; Rec."License Term")
                {
                }
                field("Total Licenses"; Rec."Total Licenses")
                {
                }
                field("Valid Since Date"; Rec."Valid Since Date")
                {
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Period Months"; Rec."Period Months")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        LicenseMgt.SyncLicensePools(false);
    end;
}
