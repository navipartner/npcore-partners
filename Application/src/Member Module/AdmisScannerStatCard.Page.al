page 6060080 "NPR Admis. Scanner Stat. Card"
{
    Extensible = False;

    Caption = 'NPR MM Admis. Scanner Station Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR MM Admis. Scanner Stations";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Activated; Rec.Activated)
                {

                    ToolTip = 'Specifies the value of the Activated field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
        area(factboxes)
        {
            part(AdmisScannStatFactbox; "NPR Adm. Scanner Stat. Factbox")
            {
                Caption = 'Images';

                SubPageLink = "Scanner Station Id" = FIELD("Scanner Station Id");
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

}
