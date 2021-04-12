page 6059974 "NPR Variety Matrix"
{
    // VRT1.10/JDH /20151202 CASE 201022 create table copy added as an action
    // VRT1.11/MHA /20160411 CASE 236840 Increased column count from 32 to 100 and added HideInactive filter and Changed parameter Item2 to VAR in function SetRecordRef() in order to parse filters
    // VRT1.11/TS  /20160509 CASE 238348  Added SETCURRENTKEY
    // NPR5.28/JDH /20161128 CASE 255961 Added OnDrillDown
    // VRT1.20/JDH /20161214 CASE 260545 Total Quantity added (on for field 15) moved code from onlookup to ondrilldown, due to web client failure
    // NPR5.31/JDH /20170502 CASE 271133 Support for next set and previous set, and thereby support for unlimited no of columns
    // NPR5.32/JDH /20170510 CASE 274170 Variable Cleanup
    // NPR5.36/JDH /20170921 CASE 288696 Added Fieldvalue to event publisher
    // NPR5.36/NPKNAV/20171003  CASE 285733 Transport NPR5.36 - 3 October 2017
    // NPR5.41/TS  /20180105 CASE 300893 Removed BalnkZero
    // NPR5.47/NPKNAV/20181026  CASE 324997-01 Transport NPR5.47 - 26 October 2018

    Caption = 'Variety Matrix';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Variety Buffer";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Variety 1 Sort Order", "Variety 2 Sort Order", "Variety 3 Sort Order", "Variety 4 Sort Order");

    layout
    {
        area(content)
        {
            group(Control6150615)
            {
                ShowCaption = false;
                field(ShowField; CurrVRTField.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Show Field';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Show Field field';

                    trigger OnDrillDown()
                    begin
                        if PAGE.RunModal(0, CurrVRTField) = ACTION::LookupOK then
                            UpdateMatrix(false); //-NPR5.36 Parameter added;
                    end;
                }
                field(ShowAsCrossVRT; ShowAsCrossVRT)
                {
                    ApplicationArea = All;
                    Caption = 'Show Horisontal';
                    ToolTip = 'Specifies the value of the Show Horisontal field';

                    trigger OnValidate()
                    begin
                        //-NPR5.31 [271133]
                        MATRIX_GenerateColumnCaptions(0, Item, ShowAsCrossVRT);
                        //+NPR5.31 [271133]

                        UpdateMatrix(false); //-NPR5.36 Parameter added
                    end;
                }
                field(HideInactive; HideInactive)
                {
                    ApplicationArea = All;
                    Caption = 'Hide Inactive Values';
                    ToolTip = 'Specifies the value of the Hide Inactive Values field';

                    trigger OnValidate()
                    begin
                        //-NPR5.31 [271133]
                        MATRIX_GenerateColumnCaptions(0, Item, ShowAsCrossVRT);
                        //+NPR5.31 [271133]

                        UpdateMatrix(true); //-NPR5.36 Parameter added
                    end;
                }
            }
            repeater(Control1)
            {
                FreezeColumn = "Variety 4 Value";
                ShowCaption = false;
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Variety 1 Value"; Rec."Variety 1 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + Item."NPR Variety 1";
                    Editable = false;
                    StyleExpr = 'Strong';
                    Visible = showvariety1;
                    ToolTip = 'Specifies the value of the Variety 1 Value field';
                }
                field("Variety 2 Value"; Rec."Variety 2 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + Item."NPR Variety 2";
                    Editable = false;
                    StyleExpr = 'Strong';
                    Visible = showvariety2;
                    ToolTip = 'Specifies the value of the Variety 2 Value field';
                }
                field("Variety 3 Value"; Rec."Variety 3 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + Item."NPR Variety 3";
                    Editable = false;
                    StyleExpr = 'Strong';
                    Visible = showvariety3;
                    ToolTip = 'Specifies the value of the Variety 3 Value field';
                }
                field("Variety 4 Value"; Rec."Variety 4 Value")
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + Item."NPR Variety 4";
                    Editable = false;
                    Visible = showvariety4;
                    ToolTip = 'Specifies the value of the Variety 4 Value field';
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[1] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(1); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[2] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(2); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[3] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(3); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[4] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(4); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[5] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(5); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[6] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(6);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(6); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[7] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(7); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[8] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(8); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[9] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(9); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[10] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(10); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[11] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(11); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[12] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(12);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(12); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(12);
                    end;
                }
                field(Field13; MATRIX_CellData[13])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[13];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[13] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(13);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(13); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(13);
                    end;
                }
                field(Field14; MATRIX_CellData[14])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[14];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[14] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(14);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(14); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(14);
                    end;
                }
                field(Field15; MATRIX_CellData[15])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[15];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[15] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(15);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(15); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(15);
                    end;
                }
                field(Field16; MATRIX_CellData[16])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[16];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[16] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(16);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(16); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(16);
                    end;
                }
                field(Field17; MATRIX_CellData[17])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[17];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[17] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(17);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(17); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(17);
                    end;
                }
                field(Field18; MATRIX_CellData[18])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[18];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[18] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(18);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(18); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(18);
                    end;
                }
                field(Field19; MATRIX_CellData[19])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[19];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[19] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(19);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(19); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(19);
                    end;
                }
                field(Field20; MATRIX_CellData[20])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[20];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[20] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(20);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(20); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(20);
                    end;
                }
                field(Field21; MATRIX_CellData[21])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[21];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[21] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(21);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(21); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(21);
                    end;
                }
                field(Field22; MATRIX_CellData[22])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[22];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[22] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(22);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(22); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(22);
                    end;
                }
                field(Field23; MATRIX_CellData[23])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[23];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[23] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(23);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(23); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(23);
                    end;
                }
                field(Field24; MATRIX_CellData[24])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[24];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[24] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(24);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(24); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(24);
                    end;
                }
                field(Field25; MATRIX_CellData[25])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[25];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[25] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(25);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(25); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(25);
                    end;
                }
                field(Field26; MATRIX_CellData[26])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[26];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[26] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(26);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(26); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(26);
                    end;
                }
                field(Field27; MATRIX_CellData[27])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[27];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[27] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(27);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(27); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(27);
                    end;
                }
                field(Field28; MATRIX_CellData[28])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[28];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[28] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(28);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(28); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(28);
                    end;
                }
                field(Field29; MATRIX_CellData[29])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[29];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[29] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(29);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(29); //-NPR5.47 [324997]
                    end;

                    trigger OnValidate()
                    begin
                        SetValue(29);
                    end;
                }
                field(Field30; MATRIX_CellData[30])
                {
                    ApplicationArea = All;
                    CaptionClass = '3,' + MATRIX_CaptionSet[30];
                    StyleExpr = 'Strong';
                    ToolTip = 'Specifies the value of the MATRIX_CellData[30] field';

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(30);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        MATRIX_OnLookup(30); //-NPR5.47 [324997]
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
                        field("CurrVRTField.Description"; CurrVRTField.Description)
                        {
                            ApplicationArea = All;
                            Caption = 'Currently Showing';
                            ToolTip = 'Specifies the value of the Currently Showing field';
                        }
                        field("CurrVRTField.""Secondary Description"""; CurrVRTField."Secondary Description")
                        {
                            ApplicationArea = All;
                            Caption = 'Show in ()';
                            ToolTip = 'Specifies the value of the Show in () field';
                        }
                        field(Total; Total)
                        {
                            ApplicationArea = All;
                            //BlankZero = true;
                            Caption = 'Total';
                            //DecimalPlaces = 0:5;
                            Enabled = ShowTotal;
                            ToolTip = 'Specifies the value of the Total field';
                        }
                    }
                    group("Variety 1")
                    {
                        Caption = 'Variety 1';
                        field("Item.""Variety 1"""; Item."NPR Variety 1")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 1 field';
                        }
                        field("Item.""Variety 1 Table"""; Item."NPR Variety 1 Table")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 1 Table field';

                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(Item, 0);

                                //-NPR5.36 [285733]
                                VRTMatrixMgt.SetRecord(RecRef, Item."No.");//Is this one needed?
                                //+NPR5.36 [285733]

                                //-NPR5.31 [271133]
                                MATRIX_GenerateColumnCaptions(0, Item, ShowAsCrossVRT);
                                //+NPR5.31 [271133]

                                UpdateMatrix(true); //-NPR5.36 Parameter added
                            end;
                        }
                    }
                    group("Variety 2")
                    {
                        Caption = 'Variety 2';
                        field("Item.""Variety 2"""; Item."NPR Variety 2")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 2 field';
                        }
                        field("Item.""Variety 2 Table"""; Item."NPR Variety 2 Table")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 2 Table field';

                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(Item, 1);
                                VRTMatrixMgt.SetRecord(RecRef, Item."No.");
                                //-NPR5.31 [271133]
                                MATRIX_GenerateColumnCaptions(0, Item, ShowAsCrossVRT);
                                //+NPR5.31 [271133]

                                UpdateMatrix(true); //-NPR5.36 Parameter added
                            end;
                        }
                    }
                    group("Variety 3")
                    {
                        Caption = 'Variety 3';
                        field("Item.""Variety 3"""; Item."NPR Variety 3")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 3 field';
                        }
                        field("Item.""Variety 3 Table"""; Item."NPR Variety 3 Table")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 3 Table field';

                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(Item, 2);
                                VRTMatrixMgt.SetRecord(RecRef, Item."No.");
                                //-NPR5.31 [271133]
                                MATRIX_GenerateColumnCaptions(0, Item, ShowAsCrossVRT);
                                //+NPR5.31 [271133]

                                UpdateMatrix(true); //-NPR5.36 Parameter added
                            end;
                        }
                    }
                    group("Variety 4")
                    {
                        Caption = 'Variety 4';
                        field("Item.""Variety 4"""; Item."NPR Variety 4")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 4 field';
                        }
                        field("Item.""Variety 4 Table"""; Item."NPR Variety 4 Table")
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Item.NPR Variety 4 Table field';

                            trigger OnDrillDown()
                            var
                                VRTLookupFunc: Codeunit "NPR Variety Lookup Functions";
                            begin
                                VRTLookupFunc.LookupVarietyValues(Item, 3);
                                VRTMatrixMgt.SetRecord(RecRef, Item."No.");
                                //-NPR5.31 [271133]
                                MATRIX_GenerateColumnCaptions(0, Item, ShowAsCrossVRT);
                                //+NPR5.31 [271133]

                                UpdateMatrix(true); //-NPR5.36 Parameter added
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Table Copy")
            {
                Caption = 'Create Table Copy';
                Image = CopyFixedAssets;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Table Copy action';

                trigger OnAction()
                var
                    VRTCloneData: Codeunit "NPR Variety Clone Data";
                begin
                    //-VRT1.10
                    VRTCloneData.CreateTableCopy(Item, 0, false);
                    CurrPage.Update(false);
                    //+VRT1.10
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    MATRIX_Step: Option Initial,Previous,Same,Next;
                begin
                    MATRIX_GenerateColumnCaptions(MATRIX_Step::Previous, Item, ShowAsCrossVRT);
                    UpdateMatrix(false); //-NPR5.36 Parameter added;
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    MATRIX_Step: Option Initial,Previous,Same,Next;
                begin
                    MATRIX_GenerateColumnCaptions(MATRIX_Step::Next, Item, ShowAsCrossVRT);
                    UpdateMatrix(false); //-NPR5.36 Parameter added
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
        ShowAsCrossVRT := Item."NPR Cross Variety No.";
        //-NPR5.31 [271133]
        MATRIX_GenerateColumnCaptions(0, Item, ShowAsCrossVRT);
        //+NPR5.31 [271133]

        UpdateMatrix(true); //-NPR5.36 Parameter added
    end;

    var
        VarietySetup: Record "NPR Variety Setup";
        MatrixRecords: array[30] of Record "NPR Variety Buffer" temporary;
        MATRIX_CurrentNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[30] of Text[1024];
        Item: Record Item;
        ShowAsCrossVRT: Option Variety1,Variety2,Variety3,Variety4;
        RecRef: RecordRef;
        VRTMatrixMgt: Codeunit "NPR Variety Matrix Management";
        CurrVRTField: Record "NPR Variety Field Setup";
        ShowVariety1: Boolean;
        ShowVariety2: Boolean;
        ShowVariety3: Boolean;
        ShowVariety4: Boolean;
        MATRIX_MatrixRecords: array[30] of Record "NPR Variety Buffer" temporary;
        MATRIX_CaptionSet: array[30] of Text[1024];
        MATRIX_CaptionRange: Text[1024];
        MATRIX_PrimKeyFirstCaptionInCu: Text[1024];
        MATRIX_CurrentNoOfColumns: Integer;
        HideInactive: Boolean;
        Initialized: Boolean;
        Total: Text;
        ShowTotal: Boolean;
        ItemFilters: Record Item;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        VarietySetup.Get();
        VarietySetup.TestField("Variety Enabled", true);

        HideInactive := VarietySetup."Hide Inactive Values";
        Initialized := true;
    end;

    procedure Load(MatrixColumns1: array[100] of Text[1024]; var MatrixRecords1: array[100] of Record "NPR Variety Buffer"; CurrentNoOfMatrixColumns: Integer)
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
        VRTBuffer: Record "NPR Variety Buffer" temporary;
        FieldValue: Text[1024];
    begin
        //-NPR5.47 [324997]
        //MatrixRecord := MatrixRecords[MATRIX_ColumnOrdinal];
        //+NPR5.47 [324997]

        VRTBuffer := Rec;
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                VRTBuffer."Variety 1 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety2:
                VRTBuffer."Variety 2 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety3:
                VRTBuffer."Variety 3 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety4:
                VRTBuffer."Variety 4 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
        end;

        //-NPR5.36 [288696]
        //VRTMatrixMgt.OnDrillDown(VRTBuffer, CurrVRTField);
        FieldValue := MATRIX_CellData[MATRIX_ColumnOrdinal];
        VRTMatrixMgt.OnDrillDown(VRTBuffer, CurrVRTField, FieldValue, ItemFilters); //-NPR5.47 [327541] Added itemFilters
        if FieldValue = MATRIX_CellData[MATRIX_ColumnOrdinal] then
            exit;
        MATRIX_CellData[MATRIX_ColumnOrdinal] := FieldValue;
        SetValue(MATRIX_ColumnOrdinal);
        //+NPR5.36 [288696]
    end;

    local procedure MATRIX_OnLookup(MATRIX_ColumnOrdinal: Integer)
    var
        VRTBuffer: Record "NPR Variety Buffer" temporary;
        FieldValue: Text[1024];
    begin
        //-NPR5.47 [324997]
        VRTBuffer := Rec;
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                VRTBuffer."Variety 1 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety2:
                VRTBuffer."Variety 2 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety3:
                VRTBuffer."Variety 3 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety4:
                VRTBuffer."Variety 4 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
        end;

        FieldValue := MATRIX_CellData[MATRIX_ColumnOrdinal];

        VRTMatrixMgt.OnLookup(VRTBuffer, CurrVRTField, FieldValue, ItemFilters);

        if FieldValue = MATRIX_CellData[MATRIX_ColumnOrdinal] then
            exit;
        MATRIX_CellData[MATRIX_ColumnOrdinal] := FieldValue;
        SetValue(MATRIX_ColumnOrdinal);
        //+NPR5.47 [324997]
    end;

    local procedure MATRIX_OnAfterGetRecord(MATRIX_ColumnOrdinal: Integer)
    var
        VRTBuffer: Record "NPR Variety Buffer" temporary;
    begin
        //-NPR5.47 [324997]
        //MatrixRecord := MatrixRecords[MATRIX_ColumnOrdinal];
        //+NPR5.47 [324997]

        VRTBuffer := Rec;
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                VRTBuffer."Variety 1 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety2:
                VRTBuffer."Variety 2 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety3:
                VRTBuffer."Variety 3 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
            ShowAsCrossVRT::Variety4:
                VRTBuffer."Variety 4 Value" := MATRIX_CaptionSet[MATRIX_ColumnOrdinal];
        end;

        MATRIX_CellData[MATRIX_ColumnOrdinal] := VRTMatrixMgt.GetValue(VRTBuffer."Variety 1 Value", VRTBuffer."Variety 2 Value",
                                                 VRTBuffer."Variety 3 Value", VRTBuffer."Variety 4 Value",
                                                 //-NPR5.47 [327541]
                                                 //CurrVRTField, LocationFilter, GD1, GD2);
                                                 CurrVRTField, ItemFilters);
        //+NPR5.47 [327541]
    end;

    procedure UpdateMatrix(ReloadMatrixData: Boolean)
    begin
        Clear(Rec);
        //-NPR5.31 [271133]
        //MATRIX_GenerateColumnCaptions(0,Item, ShowAsCrossVRT);
        //+NPR5.31 [271133]

        Load(MATRIX_CaptionSet, MATRIX_MatrixRecords, MATRIX_CurrentNoOfColumns);
        //-NPR5.36 [285733]
        //LoadMatrixRecords(Rec, Item."No.", ShowAsCrossVRT);
        Rec.LoadMatrixRows(Rec, Item, ShowAsCrossVRT, HideInactive);
        if ReloadMatrixData then
            VRTMatrixMgt.LoadMatrixData(Item."No.", HideInactive);
        //+NPR5.36 [285733]

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

        ShowVariety1 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety1) and (Item."NPR Variety 1" <> ''));
        ShowVariety2 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety2) and (Item."NPR Variety 2" <> ''));
        ShowVariety3 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety3) and (Item."NPR Variety 3" <> ''));
        ShowVariety4 := ((ShowAsCrossVRT <> ShowAsCrossVRT::Variety4) and (Item."NPR Variety 4" <> ''));

        //-NPR5.36 [285733]
        // //-VRT1.11
        //Rec.FindFirst();
        // IF HideInactive THEN BEGIN
        //  IF FindSet() then
        //    REPEAT
        //      ItemVariant.SETRANGE("Item No.",Item."No.");
        //      ItemVariant.SETRANGE("Variety 1 Value","Variety 1 Value");
        //      ItemVariant.SETRANGE(Blocked,FALSE);
        //
        //      ItemVariant2.SETRANGE("Item No.",Item."No.");
        //      ItemVariant2.SETRANGE("Variety 2 Value","Variety 2 Value");
        //      ItemVariant2.SETRANGE(Blocked,FALSE);
        //
        //      ItemVariant3.SETRANGE("Item No.",Item."No.");
        //      ItemVariant3.SETRANGE("Variety 3 Value","Variety 3 Value");
        //      ItemVariant3.SETRANGE(Blocked,FALSE);
        //
        //      ItemVariant4.SETRANGE("Item No.",Item."No.");
        //      ItemVariant4.SETRANGE("Variety 4 Value","Variety 4 Value");
        //      ItemVariant4.SETRANGE(Blocked,FALSE);
        //
        //      MARK(((NOT ShowVariety1) OR ItemVariant.FINDFIRST) AND ((NOT ShowVariety2) OR ItemVariant2.FINDFIRST) AND
        //           ((NOT ShowVariety3) OR ItemVariant3.FINDFIRST) AND ((NOT ShowVariety4) OR ItemVariant4.FINDFIRST));
        //    UNTIL Next() = 0;
        //  MARKEDONLY(TRUE);
        // END;
        // IF FINDFIRST THEN;
        // //+VRT1.11
        //+NPR5.36 [285733]

        ShowTotal := CurrVRTField."Field No." = 15;
        if ShowTotal then
            Total := Format(VRTMatrixMgt.GetTotal(RecRef, CurrVRTField."Field No."))
        else
            Total := '';

        CurrPage.Update(false);
    end;

    procedure SetRecordRef(RecRef2: RecordRef; var Item2: Record Item; ShowFieldNo: Integer)
    begin
        RecRef := RecRef2;
        Item := Item2;

        //-NPR5.47 [327541]
        //LocationFilter := Item2.GETFILTER("Location Filter");
        ItemFilters.Copy(Item2);
        if Item2.GetFilter("Date Filter") = '' then
            ItemFilters.SetFilter("Date Filter", '%1', WorkDate());
        //+NPR5.47 [327541]

        VRTMatrixMgt.SetRecord(RecRef2, Item."No.");
        //CurrVRTField.SETRANGE(Type, CurrVRTField.Type::Field);
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
    end;

    procedure SetValue(FieldNumber: Integer): Text[250]
    var
        VRT1Value: Code[50];
        VRT2Value: Code[50];
        VRT3Value: Code[50];
        VRT4Value: Code[50];
    begin
        VRT1Value := Rec."Variety 1 Value";
        VRT2Value := Rec."Variety 2 Value";
        VRT3Value := Rec."Variety 3 Value";
        VRT4Value := Rec."Variety 4 Value";
        case ShowAsCrossVRT of
            ShowAsCrossVRT::Variety1:
                VRT1Value := MATRIX_CaptionSet[FieldNumber];
            ShowAsCrossVRT::Variety2:
                VRT2Value := MATRIX_CaptionSet[FieldNumber];
            ShowAsCrossVRT::Variety3:
                VRT3Value := MATRIX_CaptionSet[FieldNumber];
            ShowAsCrossVRT::Variety4:
                VRT4Value := MATRIX_CaptionSet[FieldNumber];
        end;

        VRTMatrixMgt.SetValue(VRT1Value, VRT2Value, VRT3Value, VRT4Value, CurrVRTField, MATRIX_CellData[FieldNumber]);
        //-NPR5.47 [327541]
        //MATRIX_CellData[FieldNo] := VRTMatrixMgt.GetValue(VRT1Value, VRT2Value, VRT3Value, VRT4Value, CurrVRTField, LocationFilter, GD1, GD2);
        MATRIX_CellData[FieldNumber] := VRTMatrixMgt.GetValue(VRT1Value, VRT2Value, VRT3Value, VRT4Value, CurrVRTField, ItemFilters);
        //+NPR5.47 [327541]

        if ShowTotal then
            Total := Format(VRTMatrixMgt.GetTotal(RecRef, CurrVRTField."Field No."));
        CurrPage.Update(false);
    end;

    procedure MATRIX_GenerateColumnCaptions(MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn; Item: Record Item; ShowCrossVRTNo: Option VRT1,VRT2,VRT3,VRT4)
    begin
        //-NPR5.31 [271133]
        Clear(MATRIX_MatrixRecords);
        VRTMatrixMgt.MATRIX_GenerateColumnCaptions(MATRIX_SetWanted, Item, ShowCrossVRTNo, MATRIX_CaptionSet, MATRIX_CurrentNoOfColumns, MATRIX_CaptionRange, HideInactive, MATRIX_PrimKeyFirstCaptionInCu);
        //+NPR5.31 [271133]

        if MATRIX_CurrentNoOfMatrixColumn > MATRIX_CurrentNoOfColumns then begin
            //The cross variants is decreased. Data that are outside new arraylength must be cleared;
            Clear(MATRIX_CellData);
        end;
    end;
}

