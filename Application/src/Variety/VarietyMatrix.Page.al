page 6059974 "NPR Variety Matrix"
{
    Extensible = false;
    Caption = 'Variety Matrix';
    ContextSensitiveHelpPage = 'docs/retail/varieties/how-to/create_variety/';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Variety Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting("Variety 1 Sort Order", "Variety 2 Sort Order", "Variety 3 Sort Order", "Variety 4 Sort Order");
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            group(Control6150615)
            {
                ShowCaption = false;
                field(ShowField; CurrVRTField.Description)
                {

                    Caption = 'Show Field';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Show Field field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        if Page.RunModal(0, CurrVRTField) = Action::LookupOK then
                            UpdateMatrix(false);
                    end;
                }
                field(ShowAsCrossVRT; ShowAsCrossVRT)
                {

                    Caption = 'Show Horisontal';
                    OptionCaption = 'Variety1,Variety2,Variety3,Variety4';
                    ToolTip = 'Specifies the value of the Show Horisontal field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);

                        UpdateMatrix(false);
                    end;
                }
                field(HideInactive; HideInactive)
                {

                    Caption = 'Hide Inactive Values';
                    ToolTip = 'Specifies the value of the Hide Inactive Values field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);

                        UpdateMatrix(true);
                    end;
                }
                field(ShowColumnNames; ShowColumnNames)
                {
                    Caption = 'Show Column Names';
                    ToolTip = 'Specifies whether you want variety value names to be used as column names. If disabled, variety value codes will be used as matrix column names.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);
                        UpdateMatrix(false);
                    end;
                }
            }
            repeater(Control1)
            {
                FreezeColumn = "Variety 4 Value";
                ShowCaption = false;
                field(Description; Rec.Description)
                {

                    Editable = false;
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1 Value"; Rec."Variety 1 Value")
                {

                    CaptionClass = '3,' + _Item."NPR Variety 1";
                    Editable = false;
                    StyleExpr = 'Strong';
                    Visible = ShowVariety1;
                    ToolTip = 'Specifies the value of the Variety 1 Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2 Value"; Rec."Variety 2 Value")
                {

                    CaptionClass = '3,' + _Item."NPR Variety 2";
                    Editable = false;
                    StyleExpr = 'Strong';
                    Visible = ShowVariety2;
                    ToolTip = 'Specifies the value of the Variety 2 Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3 Value"; Rec."Variety 3 Value")
                {

                    CaptionClass = '3,' + _Item."NPR Variety 3";
                    Editable = false;
                    StyleExpr = 'Strong';
                    Visible = ShowVariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4 Value"; Rec."Variety 4 Value")
                {

                    CaptionClass = '3,' + _Item."NPR Variety 4";
                    Editable = false;
                    Visible = ShowVariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Value field';
                    ApplicationArea = NPRRetail;
                }
                field(Field1; MATRIX_CellData[1])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[1] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(1);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[2] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 2);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(2);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[3] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 3);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(3);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[4] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 4);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(4);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[5] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 5);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(5);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[6] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 6);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(6);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(6);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[7] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 7);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(7);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[8] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 8);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(8);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[9] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 9);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(9);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[10] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 10);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(10);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[11] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 11);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(11);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[12] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 12);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(12);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(12);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(12);
                    end;
                }
                field(Field13; MATRIX_CellData[13])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[13];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[13] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 13);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(13);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(13);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(13);
                    end;
                }
                field(Field14; MATRIX_CellData[14])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[14];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[14] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 14);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(14);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(14);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(14);
                    end;
                }
                field(Field15; MATRIX_CellData[15])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[15];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[15] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 15);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(15);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(15);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(15);
                    end;
                }
                field(Field16; MATRIX_CellData[16])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[16];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[16] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 16);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(16);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(16);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(16);
                    end;
                }
                field(Field17; MATRIX_CellData[17])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[17];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[17] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 17);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(17);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(17);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(17);
                    end;
                }
                field(Field18; MATRIX_CellData[18])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[18];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[18] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 18);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(18);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(18);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(18);
                    end;
                }
                field(Field19; MATRIX_CellData[19])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[19];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[19] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 19);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(19);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(19);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(19);
                    end;
                }
                field(Field20; MATRIX_CellData[20])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[20];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[20] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 20);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(20);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(20);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(20);
                    end;
                }
                field(Field21; MATRIX_CellData[21])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[21];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[21] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 21);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(21);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(21);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(21);
                    end;
                }
                field(Field22; MATRIX_CellData[22])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[22];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[22] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 22);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(22);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(22);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(22);
                    end;
                }
                field(Field23; MATRIX_CellData[23])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[23];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[23] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 23);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(23);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(23);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(23);
                    end;
                }
                field(Field24; MATRIX_CellData[24])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[24];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[24] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 24);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(24);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(24);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(24);
                    end;
                }
                field(Field25; MATRIX_CellData[25])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[25];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[25] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 25);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(25);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(25);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(25);
                    end;
                }
                field(Field26; MATRIX_CellData[26])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[26];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[26] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 26);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(26);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(26);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(26);
                    end;
                }
                field(Field27; MATRIX_CellData[27])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[27];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[27] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 27);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(27);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(27);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(27);
                    end;
                }
                field(Field28; MATRIX_CellData[28])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[28];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[28] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 28);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(28);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(28);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(28);
                    end;
                }
                field(Field29; MATRIX_CellData[29])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[29];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[29] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 29);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(29);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(29);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(29);
                    end;
                }
                field(Field30; MATRIX_CellData[30])
                {

                    CaptionClass = '3,' + MATRIX_CaptionSet[30];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[30] field';
                    Visible = (MATRIX_CurrentNoOfColumns >= 30);
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(30);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(30);
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(30);
                    end;
                }
            }
            group(Control6150617)
            {
                Editable = false;
                ShowCaption = false;
                fixed(Control6150628)
                {
                    ShowCaption = false;
                    group(Info)
                    {
                        Caption = 'Info';
                        field(CurrentlyShowing; CurrVRTField.Description)
                        {

                            Caption = 'Currently Showing';
                            ToolTip = 'Specifies the value of the Currently Showing field';
                            ApplicationArea = NPRRetail;
                        }
                        field(SecondaryDescription; CurrVRTField."Secondary Description")
                        {

                            Caption = 'Show in ()';
                            ToolTip = 'Specifies the value of the Show in () field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Total; Total)
                        {

                            Caption = 'Total';
                            Enabled = ShowTotal;
                            ToolTip = 'Specifies the value of the Total field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group("Variety 1")
                    {
                        Caption = 'Variety 1';
                        field(Variety1; _Item."NPR Variety 1")
                        {
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Variety 1.';
                            ApplicationArea = NPRRetail;
                        }
                        field(Variety1Table; _Item."NPR Variety 1 Table")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 1 Table field';
                            ApplicationArea = NPRRetail;
                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(_Item, 0);
                                VRTMatrixMgt.SetRecord(RecRef, _Item."No.");//Is this one needed?
                                MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);
                                UpdateMatrix(true);
                            end;
                        }
                    }
                    group("Variety 2")
                    {
                        Caption = 'Variety 2';
                        field(Variety2; _Item."NPR Variety 2")
                        {
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Variety 2.';
                            ApplicationArea = NPRRetail;
                        }
                        field(Variety2Table; _Item."NPR Variety 2 Table")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 2 Table field';
                            ApplicationArea = NPRRetail;
                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(_Item, 1);
                                VRTMatrixMgt.SetRecord(RecRef, _Item."No.");
                                MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);

                                UpdateMatrix(true);
                            end;
                        }
                    }
                    group("Variety 3")
                    {
                        Caption = 'Variety 3';
                        field(Variety3; _Item."NPR Variety 3")
                        {
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Variety 3.';
                            ApplicationArea = NPRRetail;
                        }
                        field(Variety3Table; _Item."NPR Variety 3 Table")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 3 Table field';
                            ApplicationArea = NPRRetail;
                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(_Item, 2);
                                VRTMatrixMgt.SetRecord(RecRef, _Item."No.");
                                MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);

                                UpdateMatrix(true);
                            end;
                        }
                    }
                    group("Variety 4")
                    {
                        Caption = 'Variety 4';
                        field(Variety4; _Item."NPR Variety 4")
                        {
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Variety 4.';
                            ApplicationArea = NPRRetail;
                        }
                        field(Variety4Table; _Item."NPR Variety 4 Table")
                        {

                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 4 Table field';
                            ApplicationArea = NPRRetail;
                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(_Item, 3);
                                VRTMatrixMgt.SetRecord(RecRef, _Item."No.");
                                MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);

                                UpdateMatrix(true);
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create Table Copy")
            {
                Caption = 'Create Table Copy';
                Image = CopyFixedAssets;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;

                ToolTip = 'Executes the Create Table Copy action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VRTCloneData: Codeunit "NPR Variety Clone Data";
                begin
                    VRTCloneData.CreateTableCopy(_Item, 0, false);
                    CurrPage.Update(false);
                end;
            }
            action("Previous Set")
            {
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Set';
                ApplicationArea = NPRRetail;


                trigger OnAction()
                var
                    MATRIX_Step: Option Initial,Previous,Same,Next;
                begin
                    MATRIX_GenerateColumnCaptions(MATRIX_Step::Previous, _Item, ShowAsCrossVRT);
                    UpdateMatrix(false);
                end;
            }
            action("Next Set")
            {
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Set';
                ApplicationArea = NPRRetail;


                trigger OnAction()
                var
                    MATRIX_Step: Option Initial,Previous,Same,Next;
                begin
                    MATRIX_GenerateColumnCaptions(MATRIX_Step::Next, _Item, ShowAsCrossVRT);
                    UpdateMatrix(false);
                end;
            }

            action("Clear Matrix")
            {
                Caption = 'Clear Matrix';
                Image = Delete;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Clear Matrix';
                Visible = ShowClearMatrix;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                begin
                    VRTMatrixMgt.ClearMatrixData();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MATRIX_CurrentColumnOrdinal: Integer;
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        while MATRIX_CurrentColumnOrdinal < MATRIX_CurrentNoOfMatrixColumn do begin
            MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + 1;
            MATRIX_OnAfterGetRecord(MATRIX_CurrentColumnOrdinal);
        end;
    end;

    trigger OnOpenPage()
    begin
        Initialize();
        ShowAsCrossVRT := _Item."NPR Cross Variety No.";
        MATRIX_GenerateColumnCaptions(0, _Item, ShowAsCrossVRT);
        UpdateMatrix(true);
    end;

    var
        VarietySetup: Record "NPR Variety Setup";
        MatrixRecords: array[30] of Record "NPR Variety Buffer" temporary;
        MATRIX_CurrentNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[30] of Text[1024];
        _Item: Record Item;
        ShowAsCrossVRT: Option Variety1,Variety2,Variety3,Variety4;
        RecRef: RecordRef;
        VRTMatrixMgt: Codeunit "NPR Variety Matrix Management";
        CurrVRTField: Record "NPR Variety Field Setup";
        ShowVariety1: Boolean;
        ShowVariety2: Boolean;
        ShowVariety3: Boolean;
        ShowVariety4: Boolean;
        ShowClearMatrix: Boolean;
        MATRIX_MatrixRecords: array[30] of Record "NPR Variety Buffer" temporary;
        MATRIX_CodeSet: array[30] of Text[1024];
        MATRIX_CaptionSet: array[30] of Text[1024];
        MATRIX_CaptionRange: Text;
        MATRIX_PrimKeyFirstCaptionInCu: Text;
        MATRIX_CurrentNoOfColumns: Integer;
        HideInactive: Boolean;
        Initialized: Boolean;
        Total: Text;
        ShowTotal: Boolean;
        ItemFilters: Record Item;
        ShowColumnNames: Boolean;
        MATRIX_TotalColumnNo: Integer;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        VarietySetup.Get();
        VarietySetup.TestField("Variety Enabled", true);

        HideInactive := VarietySetup."Hide Inactive Values";
        ShowColumnNames := VarietySetup."Show Column Names";
        ShowClearMatrix := VarietySetup."Allow Clear Matrix";
        Initialized := true;
    end;

    internal procedure Load(MatrixColumns1: array[100] of Text[1024]; var MatrixRecords1: array[100] of Record "NPR Variety Buffer"; CurrentNoOfMatrixColumns: Integer)
    var
        i: Integer;
    begin
        CopyArray(MATRIX_CaptionSet, MatrixColumns1, 1);
        for i := 1 to ArrayLen(MatrixRecords) do
            MatrixRecords[i].Copy(MatrixRecords1[i]);

        MATRIX_CurrentNoOfMatrixColumn := CurrentNoOfMatrixColumns;
    end;

    local procedure MATRIX_OnDrillDown(MATRIX_ColumnOrdinal: Integer)
    var
        TempVRTBuffer: Record "NPR Variety Buffer" temporary;
        FieldValue: Text[1024];
    begin
        TempVRTBuffer := Rec;
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                TempVRTBuffer."Variety 1 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety2:
                TempVRTBuffer."Variety 2 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety3:
                TempVRTBuffer."Variety 3 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety4:
                TempVRTBuffer."Variety 4 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
        end;

        if MATRIX_ColumnOrdinal = MATRIX_TotalColumnNo then begin
            VRTMatrixMgt.OnDrillDownTotal(TempVRTBuffer, ShowAsCrossVRT, CurrVRTField, ItemFilters);
            exit;
        end;

        FieldValue := MATRIX_CellData[MATRIX_ColumnOrdinal];
        VRTMatrixMgt.OnDrillDown(TempVRTBuffer, CurrVRTField, FieldValue, ItemFilters);
        if FieldValue = MATRIX_CellData[MATRIX_ColumnOrdinal] then
            exit;
        MATRIX_CellData[MATRIX_ColumnOrdinal] := FieldValue;
        SetValue(MATRIX_ColumnOrdinal);
    end;

    local procedure MATRIX_OnLookup(MATRIX_ColumnOrdinal: Integer)
    var
        TempVRTBuffer: Record "NPR Variety Buffer" temporary;
        FieldValue: Text[1024];
    begin
        TempVRTBuffer := Rec;
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                TempVRTBuffer."Variety 1 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety2:
                TempVRTBuffer."Variety 2 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety3:
                TempVRTBuffer."Variety 3 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety4:
                TempVRTBuffer."Variety 4 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
        end;

        if MATRIX_ColumnOrdinal = MATRIX_TotalColumnNo then begin
            VRTMatrixMgt.OnLookupTotal(TempVRTBuffer, ShowAsCrossVRT, CurrVRTField, ItemFilters);
            exit;
        end;
        FieldValue := MATRIX_CellData[MATRIX_ColumnOrdinal];
        VRTMatrixMgt.OnLookup(TempVRTBuffer, CurrVRTField, FieldValue, ItemFilters);

        if FieldValue = MATRIX_CellData[MATRIX_ColumnOrdinal] then
            exit;
        MATRIX_CellData[MATRIX_ColumnOrdinal] := FieldValue;
        SetValue(MATRIX_ColumnOrdinal);
    end;

    local procedure MATRIX_OnAfterGetRecord(MATRIX_ColumnOrdinal: Integer)
    var
        TempVRTBuffer: Record "NPR Variety Buffer" temporary;
    begin
        TempVRTBuffer := Rec;
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                TempVRTBuffer."Variety 1 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety2:
                TempVRTBuffer."Variety 2 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety3:
                TempVRTBuffer."Variety 3 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety4:
                TempVRTBuffer."Variety 4 Value" := MATRIX_CodeSet[MATRIX_ColumnOrdinal];
        end;
        if MATRIX_ColumnOrdinal = MATRIX_TotalColumnNo then
            MATRIX_CellData[MATRIX_ColumnOrdinal] := VRTMatrixMgt.GetTotalValue(TempVRTBuffer, ShowAsCrossVRT, CurrVRTField, ItemFilters)
        else
            MATRIX_CellData[MATRIX_ColumnOrdinal] := VRTMatrixMgt.GetValue(TempVRTBuffer."Variety 1 Value", TempVRTBuffer."Variety 2 Value",
                                                     TempVRTBuffer."Variety 3 Value", TempVRTBuffer."Variety 4 Value",
                                                     CurrVRTField, ItemFilters);
    end;

    internal procedure UpdateMatrix(ReloadMatrixData: Boolean)
    begin
        AddRemoveTotalColumn();
        Clear(Rec);

        Load(MATRIX_CaptionSet, MATRIX_MatrixRecords, MATRIX_CurrentNoOfColumns);
        Rec.LoadMatrixRows(Rec, _Item, ShowAsCrossVRT, HideInactive);
        if ReloadMatrixData then
            VRTMatrixMgt.LoadMatrixData(_Item."No.", HideInactive);

        //Are the sorting order 100% correct with 3 or 4 Variety in use?
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                Rec.SetCurrentKey("Variety 2 Sort Order", "Variety 3 Sort Order", "Variety 4 Sort Order", "Variety 1 Sort Order");
            ShowAsCrossVRT::Variety2:
                Rec.SetCurrentKey("Variety 3 Sort Order", "Variety 4 Sort Order", "Variety 1 Sort Order", "Variety 2 Sort Order");
            ShowAsCrossVRT::Variety3:
                Rec.SetCurrentKey("Variety 4 Sort Order", "Variety 1 Sort Order", "Variety 2 Sort Order", "Variety 3 Sort Order");
            ShowAsCrossVRT::Variety4:
                Rec.SetCurrentKey("Variety 1 Sort Order", "Variety 2 Sort Order", "Variety 3 Sort Order", "Variety 4 Sort Order");
        end;

        ShowVariety1 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety1) and (_Item."NPR Variety 1" <> ''));
        ShowVariety2 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety2) and (_Item."NPR Variety 2" <> ''));
        ShowVariety3 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety3) and (_Item."NPR Variety 3" <> ''));
        ShowVariety4 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety4) and (_Item."NPR Variety 4" <> ''));

        ShowTotal := CurrVRTField."Field No." = 15;
        if ShowTotal then
            Total := Format(VRTMatrixMgt.GetTotal(RecRef, CurrVRTField."Field No."))
        else
            Total := '';

        CurrPage.Update(false);
    end;

    internal procedure SetRecordRef(RecRef2: RecordRef; var Item2: Record Item; ShowFieldNo: Integer)
    begin
        RecRef := RecRef2;
        _Item := Item2;

        ItemFilters.Copy(Item2);
        if Item2.GetFilter("Date Filter") = '' then
            ItemFilters.SetFilter("Date Filter", '%1', WorkDate());

        VRTMatrixMgt.SetRecord(RecRef2, _Item."No.");
        CurrVRTField.SetRange("Table No.", RecRef.Number);
        if ShowFieldNo <> 0 then
            CurrVRTField.SetRange("Field No.", ShowFieldNo)
        else
            CurrVRTField.SetRange("Is Table Default", true);

        if not CurrVRTField.FindFirst() then begin
            CurrVRTField.SetRange("Field No.");
            CurrVRTField.SetRange("Is Table Default");
            CurrVRTField.FindFirst();
        end;
        CurrVRTField.SetRange("Field No.");
        CurrVRTField.SetRange("Is Table Default");
        OnAfterSetRecordRefFilters(ItemFilters, _Item, RecRef);
    end;

    internal procedure SetValue(FieldNumber: Integer): Text[250]
    var
        VRT1Value: Code[50];
        VRT2Value: Code[50];
        VRT3Value: Code[50];
        VRT4Value: Code[50];
    begin
        if FieldNumber = MATRIX_TotalColumnNo then
            Error('');
        VRT1Value := Rec."Variety 1 Value";
        VRT2Value := Rec."Variety 2 Value";
        VRT3Value := Rec."Variety 3 Value";
        VRT4Value := Rec."Variety 4 Value";
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                VRT1Value := MATRIX_CodeSet[FieldNumber];
            ShowAsCrossVRT::Variety2:
                VRT2Value := MATRIX_CodeSet[FieldNumber];
            ShowAsCrossVRT::Variety3:
                VRT3Value := MATRIX_CodeSet[FieldNumber];
            ShowAsCrossVRT::Variety4:
                VRT4Value := MATRIX_CodeSet[FieldNumber];
        end;

        VRTMatrixMgt.SetValue(VRT1Value, VRT2Value, VRT3Value, VRT4Value, CurrVRTField, MATRIX_CellData[FieldNumber]);
        MATRIX_CellData[FieldNumber] := VRTMatrixMgt.GetValue(VRT1Value, VRT2Value, VRT3Value, VRT4Value, CurrVRTField, ItemFilters);

        if ShowTotal then
            Total := Format(VRTMatrixMgt.GetTotal(RecRef, CurrVRTField."Field No."));
    end;

    internal procedure MATRIX_GenerateColumnCaptions(MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn; Item: Record Item; ShowCrossVRTNo: Option VRT1,VRT2,VRT3,VRT4)
    begin
        Clear(MATRIX_MatrixRecords);
        VRTMatrixMgt.MATRIX_GenerateColumnCaptions(MATRIX_SetWanted, Item, ShowCrossVRTNo, MATRIX_CodeSet, MATRIX_CaptionSet, MATRIX_CurrentNoOfColumns, MATRIX_CaptionRange, HideInactive, ShowColumnNames, MATRIX_PrimKeyFirstCaptionInCu);

        MATRIX_TotalColumnNo := 0;
        if CurrVRTField."Show Total Column" then
            AddRemoveTotalColumn();
        if MATRIX_CurrentNoOfMatrixColumn > MATRIX_CurrentNoOfColumns then begin
            //The cross variants is decreased. Data that are outside new arraylength must be cleared;
            Clear(MATRIX_CellData);
        end;
    end;

    local procedure AddRemoveTotalColumn()
    var
        TotalLbl: Label 'Total';
    begin
        if not (CurrVRTField."Show Total Column") then begin
            if MATRIX_TotalColumnNo <> 0 then begin
                MATRIX_CodeSet[MATRIX_TotalColumnNo] := '';
                MATRIX_CaptionSet[MATRIX_TotalColumnNo] := '';
                MATRIX_CurrentNoOfColumns -= 1;
                MATRIX_TotalColumnNo := 0;
            end;
        end else
            if MATRIX_TotalColumnNo = 0 then
                if MATRIX_CurrentNoOfColumns < ArrayLen(MATRIX_CodeSet) then begin
                    MATRIX_CodeSet[MATRIX_CurrentNoOfColumns + 1] := '';
                    MATRIX_CaptionSet[MATRIX_CurrentNoOfColumns + 1] := TotalLbl;
                    MATRIX_CurrentNoOfColumns += 1;
                    MATRIX_TotalColumnNo := MATRIX_CurrentNoOfColumns;
                end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetRecordRefFilters(var ItemFilters: Record Item; Item: Record Item; RecRef: RecordRef)
    begin
    end;
}

