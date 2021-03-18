page 6151588 "NPR Event Atributes Info"
{
    Caption = 'Event Atributes Info';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Event Attribute";

    layout
    {
        area(content)
        {
            repeater(Control6014403)
            {
                ShowCaption = false;
                field("Template Name"; "Template Name")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = UseAttributeMatrix;
                    ToolTip = 'Specifies the value of the Template Name field';
                }
                field(Promote; Promote)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = UseAttributeMatrix;
                    ToolTip = 'Specifies the value of the Promote field';
                }
                field(UseAttributeMatrix; UseAttributeMatrix)
                {
                    ApplicationArea = All;
                    Caption = 'Attribute Matrix Suggested';
                    Style = Attention;
                    StyleExpr = UseAttributeMatrix;
                    ToolTip = 'Specifies the value of the Attribute Matrix Suggested field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Matrix)
            {
                Caption = 'Matrix';
                Image = ShowMatrix;
                ApplicationArea = All;
                ToolTip = 'Executes the Matrix action';

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "NPR Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetJob("Job No.");
                    EventAttributeMatrix.SetAttrTemplate("Template Name");
                    EventAttributeMatrix.Run
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EventAttributeTemplate.Get("Template Name");

        EventAttributeRowValue.Reset;
        EventAttributeRowValue.SetRange("Template Name", EventAttributeTemplate."Row Template Name");
        NoOfRows := EventAttributeRowValue.Count;
        EventAttributeRowValue.SetRange(Promote, true);
        NoOfPromotedRows := EventAttributeRowValue.Count;

        EventAttributeColValue.Reset;
        EventAttributeColValue.SetRange("Template Name", EventAttributeTemplate."Column Template Name");
        NoOfColumns := EventAttributeColValue.Count;
        EventAttributeColValue.SetRange(Promote, true);
        NoOfPromotedColumns := EventAttributeColValue.Count;

        UseAttributeMatrix := (MaxNoOfRows < NoOfRows) or (NoOfPromotedRows < NoOfRows) or (MaxNoOfColumns < NoOfColumns) or (NoOfPromotedColumns < NoOfColumns);
    end;

    trigger OnOpenPage()
    begin
        MaxNoOfRows := EventCard.GetArrayLen(1);
        MaxNoOfColumns := EventCard.GetArrayLen(2);
    end;

    var
        NoOfRows: Integer;
        NoOfColumns: Integer;
        NoOfPromotedRows: Integer;
        NoOfPromotedColumns: Integer;
        EventCard: Page "NPR Event Card";
        MaxNoOfColumns: Integer;
        MaxNoOfRows: Integer;
        EventAttributeTemplate: Record "NPR Event Attribute Template";
        EventAttributeRowValue: Record "NPR Event Attr. Row Value";
        EventAttributeColValue: Record "NPR Event Attr. Column Value";
        UseAttributeMatrix: Boolean;
}

