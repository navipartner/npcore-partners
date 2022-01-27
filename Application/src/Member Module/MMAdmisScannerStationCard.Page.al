page 6060080 "NPR Admis. Scanner Stat. Card"
{
    Extensible = False;

    Caption = 'NPR MM Admis. Scanner Station Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR MM Admis. Scanner Stations";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Activated; Rec.Activated)
                {

                    ToolTip = 'Specifies the value of the Activated field';
                    ApplicationArea = NPRRetail;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(AdmisScannStatFactbox; "NPR Adm. Scanner Stat. Factbox")
            {
                Caption = 'Images';

                SubPageLink = "Scanner Station Id" = FIELD("Scanner Station Id");
                ApplicationArea = NPRRetail;
            }
        }
    }

}
