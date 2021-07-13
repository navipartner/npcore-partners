page 6151400 "NPR Magento Gen. Setup Buffer"
{
    Caption = 'Generic Setup';
    DataCaptionFields = "Root Element";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Gen. Setup Buffer";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

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
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    Enabled = NOT Rec.Container;
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type"; Rec."Data Type")
                {

                    Enabled = false;
                    ToolTip = 'Specifies the value of the Data Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."Root Element" <> '' then
            CurrPage.Caption(Rec."Root Element");
    end;

    procedure SetEditable(IsEditable: Boolean)
    begin
        CurrPage.Editable(IsEditable);
    end;

    procedure SetSourceTable(var TempGenericSetupBuffer: Record "NPR Magento Gen. Setup Buffer" temporary)
    begin
        Rec.Copy(TempGenericSetupBuffer, true);
    end;
}