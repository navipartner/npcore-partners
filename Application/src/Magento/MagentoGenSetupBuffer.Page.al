page 6151400 "NPR Magento Gen. Setup Buffer"
{
    Caption = 'Generic Setup';
    DataCaptionFields = "Root Element";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Gen. Setup Buffer";
    SourceTableTemporary = true;

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
                    ApplicationArea = All;
                    Enabled = false;
                    Style = Strong;
                    StyleExpr = Rec.Container;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    Enabled = NOT Rec.Container;
                    ToolTip = 'Specifies the value of the Value field';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ApplicationArea = All;
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Data Type field';
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