page 6060080 "NPR Admis. Scanner Stat. Card"
{

    Caption = 'NPR MM Admis. Scanner Station Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Admis. Scanner Stations";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {
                    ApplicationArea = All;
                }
                field(Activated; Rec.Activated)
                {
                    ApplicationArea = All;
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            part(AdmisScannStatFactbox; "NPR Adm. Scanner Stat. Factbox")
            {
                Caption = 'Images';
                ApplicationArea = All;
                SubPageLink = "Scanner Station Id" = FIELD("Scanner Station Id");
            }
        }
    }

}