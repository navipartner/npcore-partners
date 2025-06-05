page 6151400 "NPR Magento Gen. Setup Buffer"
{
    Extensible = False;
    Caption = 'Generic Setup';
    DataCaptionFields = "Root Element";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Gen. Setup Buffer";
    SourceTableTemporary = true;
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Name;
                ShowAsTree = true;
                field(Name; Rec.Name)
                {

                    Enabled = false;
                    Style = Strong;
                    StyleExpr = Rec.Container;
                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRMagento;
                }
                field(Value; Rec.Value)
                {

                    Enabled = NOT Rec.Container;
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRMagento;
                }
                field("Data Type"; Rec."Data Type")
                {

                    Enabled = false;
                    ToolTip = 'Specifies the value of the Data Type field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Root Element" <> '' then
            CurrPage.Caption(Rec."Root Element");
    end;

    internal procedure SetEditable(IsEditable: Boolean)
    begin
        CurrPage.Editable(IsEditable);
    end;

    internal procedure SetSourceTable(var TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary)
    begin
        Rec.Copy(TempGenericSetupBuffer, true);
    end;
}
