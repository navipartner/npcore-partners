page 6060048 "NPR Reg. ItemWsht Var.Subpage"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR5.29\BR \20161209 CASE 260757 Added description

    AutoSplitKey = true;
    Caption = 'Reg. Item Wsht Variety Subpage';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Reg. Item Wsht Var. Line";
    SourceTableView = SORTING("Registered Worksheet No.", "Registered Worksheet Line No.", "Variety 1 Value", "Variety 2 Value", "Variety 3 Value", "Variety 4 Value")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                ShowAsTree = true;
                field(Level; Level)
                {
                    ApplicationArea = All;
                    AutoFormatType = 2;
                    Editable = false;
                    Visible = false;
                }
                field("Heading Text"; "Heading Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variety 1 Value"; "Variety 1 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[1];
                    Visible = Variety1InUse;
                }
                field("Variety 2 Value"; "Variety 2 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[2];
                    Visible = Variety2InUse;
                }
                field("Variety 3 Value"; "Variety 3 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[3];
                    Visible = Variety3InUse;
                }
                field("Variety 4 Value"; "Variety 4 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + FieldCaptionNew[4];
                    Visible = Variety4InUse;
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Existing Variant Code"; "Existing Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Existing Variant Blocked"; "Existing Variant Blocked")
                {
                    ApplicationArea = All;
                }
                field("Internal Bar Code"; "Internal Bar Code")
                {
                    ApplicationArea = All;
                }
                field("Vendors Bar Code"; "Vendors Bar Code")
                {
                    ApplicationArea = All;
                }
                field("Sales Price"; "Sales Price")
                {
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        FieldCaptionNew: array[4] of Text;
        RegItemWorksheetLine: Record "NPR Regist. Item Worksh Line";
        [InDataSet]
        Variety1InUse: Boolean;
        [InDataSet]
        Variety2InUse: Boolean;
        [InDataSet]
        Variety3InUse: Boolean;
        [InDataSet]
        Variety4InUse: Boolean;

    procedure SetRecFromIW(RegItemWorksheetLineHere: Record "NPR Regist. Item Worksh Line")
    begin
        RegItemWorksheetLine := RegItemWorksheetLineHere;

        FilterGroup := 2;
        SetRange("Registered Worksheet No.", RegItemWorksheetLine."Registered Worksheet No.");
        SetRange("Registered Worksheet Line No.", RegItemWorksheetLine."Line No.");
        FilterGroup := 0;

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

