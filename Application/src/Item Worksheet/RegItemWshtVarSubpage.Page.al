page 6060048 "NPR Reg. ItemWsht Var.Subpage"
{
    AutoSplitKey = true;
    Caption = 'Reg. Item Wsht Variety Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPR Reg. Item Wsht Var. Line";
    SourceTableView = SORTING("Registered Worksheet No.", "Registered Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                      ORDER(Ascending);
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Level;
                ShowAsTree = true;
                field(Level; Rec.Level)
                {

                    AutoFormatType = 2;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Level field';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Heading Text"; Rec."Heading Text")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Heading Text field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1 Value"; Rec."Variety 1 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[1];
                    ToolTip = 'Specifies the value of the Variety 1 Value field';
                    Visible = Variety1InUse;
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2 Value"; Rec."Variety 2 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[2];
                    ToolTip = 'Specifies the value of the Variety 2 Value field';
                    Visible = Variety2InUse;
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3 Value"; Rec."Variety 3 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[3];
                    ToolTip = 'Specifies the value of the Variety 3 Value field';
                    Visible = Variety3InUse;
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4 Value"; Rec."Variety 4 Value")
                {

                    CaptionClass = '3,' + FieldCaptionNew[4];
                    ToolTip = 'Specifies the value of the Variety 4 Value field';
                    Visible = Variety4InUse;
                    ApplicationArea = NPRRetail;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Existing Variant Code"; Rec."Existing Variant Code")
                {

                    ToolTip = 'Specifies the value of the Existing Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Existing Variant Blocked"; Rec."Existing Variant Blocked")
                {

                    ToolTip = 'Specifies the value of the Existing Variant Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Internal Bar Code"; Rec."Internal Bar Code")
                {

                    ToolTip = 'Specifies the value of the Internal Bar Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Vendors Bar Code"; Rec."Vendors Bar Code")
                {

                    ToolTip = 'Specifies the value of the Vendors Bar Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Price"; Rec."Sales Price")
                {

                    ToolTip = 'Specifies the value of the Sales Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {

                    ToolTip = 'Specifies the value of the Direct Unit Cost field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        RegItemWorksheetLine: Record "NPR Regist. Item Worksh Line";
        [InDataSet]
        Variety1InUse: Boolean;
        [InDataSet]
        Variety2InUse: Boolean;
        [InDataSet]
        Variety3InUse: Boolean;
        [InDataSet]
        Variety4InUse: Boolean;
        FieldCaptionNew: array[4] of Text;

    procedure SetRecFromIW(RegItemWorksheetLineHere: Record "NPR Regist. Item Worksh Line")
    begin
        RegItemWorksheetLine := RegItemWorksheetLineHere;

        Rec.FilterGroup := 2;
        Rec.SetRange("Registered Worksheet No.", RegItemWorksheetLine."Registered Worksheet No.");
        Rec.SetRange("Registered Worksheet Line No.", RegItemWorksheetLine."Line No.");
        Rec.FilterGroup := 0;

        MakeCaptions();
    end;

    local procedure MakeCaptions()
    begin
        Variety1InUse := (RegItemWorksheetLine."Variety 1" <> '') and (RegItemWorksheetLine."Variety 1 Table (New)" <> '');
        if Variety1InUse then
            FieldCaptionNew[1] := RegItemWorksheetLine."Variety 1" + '; ' + RegItemWorksheetLine."Variety 1 Table (New)";

        Variety2InUse := (RegItemWorksheetLine."Variety 2" <> '') and (RegItemWorksheetLine."Variety 2 Table (New)" <> '');
        if Variety2InUse then
            FieldCaptionNew[2] := RegItemWorksheetLine."Variety 2" + '; ' + RegItemWorksheetLine."Variety 2 Table (New)";

        Variety3InUse := (RegItemWorksheetLine."Variety 3" <> '') and (RegItemWorksheetLine."Variety 3 Table (New)" <> '');
        if Variety3InUse then
            FieldCaptionNew[3] := RegItemWorksheetLine."Variety 3" + '; ' + RegItemWorksheetLine."Variety 3 Table (New)";

        Variety4InUse := (RegItemWorksheetLine."Variety 4" <> '') and (RegItemWorksheetLine."Variety 4 Table (New)" <> '');
        if Variety4InUse then
            FieldCaptionNew[4] := RegItemWorksheetLine."Variety 4" + '; ' + RegItemWorksheetLine."Variety 4 Table (New)";
    end;

    procedure UpdateSubPage()
    begin
        CurrPage.Update(false);
    end;
}

