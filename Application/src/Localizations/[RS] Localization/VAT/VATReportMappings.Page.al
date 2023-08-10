page 6059931 "NPR VAT Report Mappings"
{
    ApplicationArea = NPRRSLocal;
    Caption = 'VAT Report Mappings';
    PageType = List;
    SourceTable = "NPR VAT Report Mapping";
    UsageCategory = Lists;
    Editable = false;
    Extensible = false;
    CardPageId = "NPR VAT Report Mapping Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRSLocal;
                }
            }
        }
    }
}
