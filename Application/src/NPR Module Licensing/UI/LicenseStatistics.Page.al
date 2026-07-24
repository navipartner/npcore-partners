page 6184517 "NPR License Statistics"
{
    Caption = 'NPR License Statistics';
    PageType = ListPart;
    SourceTable = "NPR License Stats";
    SourceTableTemporary = true;
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
                field(Module; Rec.Module)
                {
                }
                field("License Term"; Rec."License Term")
                {
                }
                field("Total Licenses"; Rec."Total Licenses")
                {
                }
                field("Used Licenses"; Rec."Used Licenses")
                {
                }
                field(Remaining; Rec.Remaining)
                {
                }
                field("Usage %"; Rec."Usage %")
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
        LicenseMgt.GetLicenseStats(Rec);
        if Rec.FindFirst() then;
    end;
}
