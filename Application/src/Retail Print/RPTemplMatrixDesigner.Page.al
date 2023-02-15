page 6014637 "NPR RP Templ. Matrix Designer"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Template Matrix Designer';
    PageType = Worksheet;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR RP Template Line";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Type Option"; Rec."Type Option")
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Type Option field';
                    ApplicationArea = NPRRetail;
                }
                field(X; Rec.X)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    Width = 4;
                    ToolTip = 'Specifies the value of the X field';
                    ApplicationArea = NPRRetail;
                }
                field(Y; Rec.Y)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    Width = 4;
                    ToolTip = 'Specifies the value of the Y field';
                    ApplicationArea = NPRRetail;
                }
                field("Prefix Next Line"; Rec."Prefix Next Line")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix Next Line field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Name"; Rec."Data Item Name")
                {

                    Style = Strong;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Operator; Rec.Operator)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Operator field';
                    ApplicationArea = NPRRetail;
                }
                field("Field 2 Name"; Rec."Field 2 Name")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Field 2 Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Attribute; Rec.Attribute)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Attribute field';
                    ApplicationArea = NPRRetail;
                }
                field(Prefix; Rec.Prefix)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Prefix field';
                    ApplicationArea = NPRRetail;
                }
                field(Postfix; Rec.Postfix)
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Postfix field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Value"; Rec."Default Value")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Default Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Value Record Required"; Rec."Default Value Record Required")
                {

                    ToolTip = 'Specifies the value of the Only Fill Default Value On Data field';
                    ApplicationArea = NPRRetail;
                }
                field(Align; Rec.Align)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Align field';
                    ApplicationArea = NPRRetail;
                }
                field(Rotation; Rec.Rotation)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Rotation field';
                    ApplicationArea = NPRRetail;
                }
                field(Width; Rec.Width)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Barcode Size/Width field';
                    ApplicationArea = NPRRetail;
                }
                field(Height; Rec.Height)
                {

                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Height field';
                    ApplicationArea = NPRRetail;
                }
                field("Hide HRI"; Rec."Hide HRI")
                {
                    Enabled = NOT (Rec."Prefix Next Line" OR (Rec."Type" = 1));
                    Style = Subordinate;
                    StyleExpr = Rec."Prefix Next Line" OR (Rec."Type" = 1);
                    ToolTip = 'Specifies the value of the Hide HRI field';
                    ApplicationArea = NPRRetail;
                }
                field("Start Char"; Rec."Start Char")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Start Char field';
                    ApplicationArea = NPRRetail;
                }
                field("Max Length"; Rec."Max Length")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Max Length field';
                    ApplicationArea = NPRRetail;
                }
                field("Blank Zero"; Rec."Blank Zero")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Blank Zero field';
                    ApplicationArea = NPRRetail;
                }
                field("Skip If Empty"; Rec."Skip If Empty")
                {

                    Enabled = NOT (Rec."Type" = 1);
                    Style = Subordinate;
                    StyleExpr = Rec."Type" = 1;
                    ToolTip = 'Specifies the value of the Skip If Empty field';
                    ApplicationArea = NPRRetail;
                }
                field("Root Record No."; Rec."Root Record No.")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Root Record No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Record No."; Rec."Data Item Record No.")
                {

                    BlankZero = true;
                    ToolTip = 'Specifies the value of the Data Item Record No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Comments; Rec.Comments)
                {

                    ToolTip = 'Specifies the value of the Comments field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Codeunit"; Rec."Processing Codeunit")
                {

                    ToolTip = 'Specifies the value of the Processing Codeunit field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Function ID"; Rec."Processing Function ID")
                {

                    ToolTip = 'Specifies the value of the Processing Function ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Function Parameter"; Rec."Processing Function Parameter")
                {

                    ToolTip = 'Specifies the value of the Processing Function Parameter field';
                    ApplicationArea = NPRRetail;
                }
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
                ToolTip = 'Executes the Unindent action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RPTemplateLine: Record "NPR RP Template Line";
                begin
                    CurrPage.SetSelectionFilter(RPTemplateLine);
                    Rec.UnindentLine(RPTemplateLine);
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
                ToolTip = 'Executes the Indent action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RPTemplateLine: Record "NPR RP Template Line";
                begin
                    CurrPage.SetSelectionFilter(RPTemplateLine);
                    Rec.IndentLine(RPTemplateLine);
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

                ToolTip = 'Executes the Test Print action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    DataItem: Record "NPR RP Data Items";
                    TemplateMgt: Codeunit "NPR RP Template Mgt.";
                    RecRef: RecordRef;
                begin
                    CurrPage.Update(true);

                    DataItem.SetRange(Code, Rec."Template Code");
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

                    TemplateMgt.PrintTemplate(Rec."Template Code", RecRef, 0);
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

                ToolTip = 'Executes the Set Test Print Filter action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    FilterPageBuilder: FilterPageBuilder;
                    DataItem: Record "NPR RP Data Items";
                begin
                    DataItem.SetRange(Code, Rec."Template Code");
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

    var
        RecordView: Text;
        RecordTableNo: Integer;
}

