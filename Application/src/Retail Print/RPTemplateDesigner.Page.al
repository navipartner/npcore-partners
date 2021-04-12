page 6014560 "NPR RP Template Designer"
{
    AutoSplitKey = true;
    Caption = 'Template Designer';
    DeleteAllowed = false;
    PageType = Document;
    UsageCategory = Administration;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Prints,Data';
    SourceTable = "NPR RP Template Header";

    layout
    {
        area(content)
        {
            part(MatrixDesigner; "NPR RP Templ. Matrix Designer")
            {
                Caption = 'Matrix Designer';
                ShowFilter = false;
                SubPageLink = "Template Code" = FIELD(Code);
                Visible = MatrixVisible;
                ApplicationArea = All;
            }
            part(LineDesigner; "NPR RP Templ. Line Designer")
            {
                Caption = 'Line Designer';
                ShowFilter = false;
                SubPageLink = "Template Code" = FIELD(Code);
                Visible = LineVisible;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Unindent)
            {
                Caption = 'Unindent';
                Image = PreviousRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Printer Type" = Rec."Printer Type"::Line;
                ApplicationArea = All;
                ToolTip = 'Executes the Unindent action';

                trigger OnAction()
                begin
                    CurrPage.LineDesigner.PAGE.UnindentLine();
                end;
            }
            action(Indent)
            {
                Caption = 'Indent';
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Printer Type" = Rec."Printer Type"::Line;
                ApplicationArea = All;
                ToolTip = 'Executes the Indent action';

                trigger OnAction()
                begin
                    CurrPage.LineDesigner.PAGE.IndentLine();
                end;
            }
            action("Test Print")
            {
                Caption = 'Test Print';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F8';
                ApplicationArea = All;
                ToolTip = 'Executes the Test Print action';

                trigger OnAction()
                var
                    DataItem: Record "NPR RP Data Items";
                    TemplateMgt: Codeunit "NPR RP Template Mgt.";
                begin
                    CurrPage.Update(true);
                    Clear(RecRef);

                    DataItem.SetRange(Code, Rec.Code);
                    DataItem.SetRange(Level, 0);
                    DataItem.FindFirst();

                    RecRef.Open(DataItem."Table ID");
                    if RecordView <> '' then begin
                        RecRef.SetView(RecordView);
                        RecRef.FindSet();
                    end else begin
                        RecRef.FindFirst();
                        RecRef.SetRecFilter();
                    end;

                    TemplateMgt.PrintTemplate(Rec.Code, RecRef, 0);
                end;
            }
            action("Set Test Print Filter")
            {
                Caption = 'Set Test Print Filter';
                Image = EditFilter;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Set Test Print Filter action';

                trigger OnAction()
                var
                    FilterPageBuilder: FilterPageBuilder;
                    DataItem: Record "NPR RP Data Items";
                begin
                    DataItem.SetRange(Code, Rec.Code);
                    DataItem.SetRange(Level, 0);
                    DataItem.FindFirst();

                    FilterPageBuilder.AddTable(DataItem."Data Source", DataItem."Table ID");
                    if (RecordView <> '') and (RecordTableNo = DataItem."Table ID") then
                        FilterPageBuilder.SetView(DataItem."Data Source", RecordView); //Reapply previously set filter

                    if FilterPageBuilder.RunModal() then begin
                        RecordView := FilterPageBuilder.GetView(DataItem."Data Source", false);
                        RecordTableNo := DataItem."Table ID";
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        TemplateHeader: Record "NPR RP Template Header";
    begin
        TemplateHeader.Get(Rec.Code);
        MatrixVisible := TemplateHeader."Printer Type" = TemplateHeader."Printer Type"::Matrix;
        LineVisible := TemplateHeader."Printer Type" = TemplateHeader."Printer Type"::Line;
    end;

    var
        RecordView: Text;
        RecordTableNo: Integer;
        RecRef: RecordRef;
        MatrixVisible: Boolean;
        LineVisible: Boolean;
}

