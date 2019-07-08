page 6151588 "Event Atributes Info"
{
    // NPR5.38/TJ  /20171122 CASE 291965 New object

    Caption = 'Event Atributes Info';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Event Attribute";

    layout
    {
        area(content)
        {
            repeater(Control6014403)
            {
                ShowCaption = false;
                field("Template Name";"Template Name")
                {
                    Style = Attention;
                    StyleExpr = UseAttributeMatrix;
                }
                field(Promote;Promote)
                {
                    Style = Attention;
                    StyleExpr = UseAttributeMatrix;
                }
                field(UseAttributeMatrix;UseAttributeMatrix)
                {
                    Caption = 'Attribute Matrix Suggested';
                    Style = Attention;
                    StyleExpr = UseAttributeMatrix;
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

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "Event Attribute Matrix";
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
        EventAttributeRowValue.SetRange("Template Name",EventAttributeTemplate."Row Template Name");
        NoOfRows := EventAttributeRowValue.Count;
        EventAttributeRowValue.SetRange(Promote,true);
        NoOfPromotedRows := EventAttributeRowValue.Count;

        EventAttributeColValue.Reset;
        EventAttributeColValue.SetRange("Template Name",EventAttributeTemplate."Column Template Name");
        NoOfColumns := EventAttributeColValue.Count;
        EventAttributeColValue.SetRange(Promote,true);
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
        EventCard: Page "Event Card";
        MaxNoOfColumns: Integer;
        MaxNoOfRows: Integer;
        EventAttributeTemplate: Record "Event Attribute Template";
        EventAttributeRowValue: Record "Event Attribute Row Value";
        EventAttributeColValue: Record "Event Attribute Column Value";
        UseAttributeMatrix: Boolean;
}

