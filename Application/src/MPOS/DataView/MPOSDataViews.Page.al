page 6059870 "NPR MPOS Data Views"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR MPOS Data View";
    Extensible = false;
    Caption = 'MPOS Data Views';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                IndentationColumn = Rec.Indent;
                IndentationControls = Description;

                field("Data View Type"; Rec."Data View Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies type of data view. Default view type is NaviConnect which refers to NaviPartner, module NaviConnect';
                    StyleExpr = IndentStyleExpr;
                }
                field("Data View Category"; Rec."Data View Category")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies category of data view. To each type different category views can be assigned.';
                    StyleExpr = IndentStyleExpr;
                }
                field("Data View Code"; Rec."Data View Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies unique value of data view. For default type NaviConnect, relation point out to Xml Templates.';
                    StyleExpr = IndentStyleExpr;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies description of selected data view.';
                    StyleExpr = IndentStyleExpr;
                }
                field("Category Default"; Rec."Category Default")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies default value per category. Only one record, under the same type and category, can be marked as a default.';
                    Visible = false;
                }
                field("Response Size"; Rec."Response Size")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies category of response size. E.g. small response size suit to camera view';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Preview)
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Preview result for specific type; type and category; type, category and code';
                Image = PreviewChecks;
                PromotedCategory = Process;
                Promoted = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    DataViewMgt: Codeunit "NPR MPOS Data View Mgt.";
                begin
                    DataViewMgt.PreviewCategory(Rec."Data View Category", Rec.SystemId);
                end;
            }
        }
    }

    var
        IndentStyleExpr: Text;

    trigger OnNewRecord(BelowRec: Boolean)
    begin
        Rec.InitRec(xRec."Data View Type", xRec."Data View Category");
    end;

    trigger OnAfterGetRecord()
    begin
        case Rec.Indent of
            0, 2:
                begin
                    IndentStyleExpr := 'None';
                end;
            1:
                begin
                    IndentStyleExpr := 'Strong';
                end;
        end;
    end;
}