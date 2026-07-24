#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248205 "NPR POS Lic. Bill. Allowances"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-06-05';
    ObsoleteReason = 'Replaced by NPR Module Licensing (page "NPR License Pools").';
    PageType = ListPart;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR POS Lic. Billing Allowance";
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(AllowancesRepeater)
            {
                field("Pool Id"; Rec."Pool Id")
                {
                    Visible = false;
                }
                field("License Type"; Rec."License Type")
                {
                }
                field("Period Months"; Rec."Period Months")
                {
                }
                field("Valid Since Date"; Rec."Valid Since Date")
                {
                    Visible = false;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                }
                field(Name; Rec.Name)
                {
                    Visible = false;
                }
                field("Total Licenses"; Rec."Total Licenses")
                {
                }
            }
        }
    }
}
#endif