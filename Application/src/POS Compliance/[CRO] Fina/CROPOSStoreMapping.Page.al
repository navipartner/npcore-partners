page 6248194 "NPR CRO POS Store Mapping"
{
    ApplicationArea = NPRCROFiscal;
    Caption = 'CRO POS Store Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR CRO POS Store Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(POSStoreMappingLines)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the POS Store Code.';
                }
                field("Bill No. Series"; Rec."Bill No. Series")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies the Bill Number Series for the related POS Store.';
                    ShowMandatory = true;
                }
            }
        }
    }
}