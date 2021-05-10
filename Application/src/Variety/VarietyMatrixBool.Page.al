page 6059978 "NPR Variety Matrix Bool"
{
    // VRT1.11/JDH /20160602 CASE 242940 Created
    // NPR5.30/JDH /20170310 CASE 266203 Transport NPR5.30 - 26 January 2017
    // NPR5.31/JDH /20170502 CASE 271133 Transport NPR5.31 - 2 May 2017
    // NPR5.32/JDH /20170509 CASE 274170 Added actions for multible creation / Blocking of Variants
    // NPR5.36/JDH /20170922 CASE 288696 Deleted Function MATRIX_OnDrillDown - it wasnt used
    // NPR5.36/NPKNAV/20171003  CASE 285733 Transport NPR5.36 - 3 October 2017
    // NPR5.41/TS  /20180105 CASE 300893 Removed Property BlankZero

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
                field("CurrVRTField.Description"; CurrVRTField.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Show Field';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Show Field field';

                    trigger OnDrillDown()
                    begin

                        //-NPR5.30 [266203]
                        if PAGE.RunModal(0, CurrVRTField) = ACTION::LookupOK then
                            UpdateMatrix(false); //-NPR5.36 Parameter added;
                        //+NPR5.30 [266203]
                    end;
                }
                field(ShowAsCrossVRT; ShowAsCrossVRT)
                {
                    ApplicationArea = All;
                    Caption = 'Show Horisontal';
                    OptionCaption = 'Variety1,Variety2,Variety3,Variety4';
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
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[1];
                    Visible = visible1;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[1] field';

                    trigger OnValidate()
                    begin
                        SetValue(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[2];
                    Visible = visible2;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[2] field';

                    trigger OnValidate()
                    begin
                        SetValue(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[3];
                    Visible = Visible3;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[3] field';

                    trigger OnValidate()
                    begin
                        SetValue(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[4];
                    Visible = Visible4;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[4] field';

                    trigger OnValidate()
                    begin
                        SetValue(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[5];
                    Visible = Visible5;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[5] field';

                    trigger OnValidate()
                    begin
                        SetValue(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[6];
                    Visible = Visible6;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[6] field';

                    trigger OnValidate()
                    begin
                        SetValue(6);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[7];
                    Visible = Visible7;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[7] field';

                    trigger OnValidate()
                    begin
                        SetValue(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[8];
                    Visible = Visible8;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[8] field';

                    trigger OnValidate()
                    begin
                        SetValue(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[9];
                    Visible = Visible9;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[9] field';

                    trigger OnValidate()
                    begin
                        SetValue(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[10];
                    Visible = Visible10;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[10] field';

                    trigger OnValidate()
                    begin
                        SetValue(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[11];
                    Visible = Visible11;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[11] field';

                    trigger OnValidate()
                    begin
                        SetValue(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[12];
                    Visible = Visible12;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[12] field';

                    trigger OnValidate()
                    begin
                        SetValue(12);
                    end;
                }
                field(Field13; MATRIX_CellData[13])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[13];
                    Visible = Visible13;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[13] field';

                    trigger OnValidate()
                    begin
                        SetValue(13);
                    end;
                }
                field(Field14; MATRIX_CellData[14])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[14];
                    Visible = Visible14;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[14] field';

                    trigger OnValidate()
                    begin
                        SetValue(14);
                    end;
                }
                field(Field15; MATRIX_CellData[15])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[15];
                    Visible = Visible15;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[15] field';

                    trigger OnValidate()
                    begin
                        SetValue(15);
                    end;
                }
                field(Field16; MATRIX_CellData[16])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[16];
                    Visible = Visible16;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[16] field';

                    trigger OnValidate()
                    begin
                        SetValue(16);
                    end;
                }
                field(Field17; MATRIX_CellData[17])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[17];
                    Visible = Visible17;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[17] field';

                    trigger OnValidate()
                    begin
                        SetValue(17);
                    end;
                }
                field(Field18; MATRIX_CellData[18])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[18];
                    Visible = Visible18;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[18] field';

                    trigger OnValidate()
                    begin
                        SetValue(18);
                    end;
                }
                field(Field19; MATRIX_CellData[19])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[19];
                    Visible = Visible19;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[19] field';

                    trigger OnValidate()
                    begin
                        SetValue(19);
                    end;
                }
                field(Field20; MATRIX_CellData[20])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[20];
                    Visible = Visible20;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[20] field';

                    trigger OnValidate()
                    begin
                        SetValue(20);
                    end;
                }
                field(Field21; MATRIX_CellData[21])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[21];
                    Visible = Visible21;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[21] field';

                    trigger OnValidate()
                    begin
                        SetValue(21);
                    end;
                }
                field(Field22; MATRIX_CellData[22])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[22];
                    Visible = Visible22;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[22] field';

                    trigger OnValidate()
                    begin
                        SetValue(22);
                    end;
                }
                field(Field23; MATRIX_CellData[23])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[23];
                    Visible = Visible23;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[23] field';

                    trigger OnValidate()
                    begin
                        SetValue(23);
                    end;
                }
                field(Field24; MATRIX_CellData[24])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[24];
                    Visible = Visible24;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[24] field';

                    trigger OnValidate()
                    begin
                        SetValue(24);
                    end;
                }
                field(Field25; MATRIX_CellData[25])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[25];
                    Visible = Visible25;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[25] field';

                    trigger OnValidate()
                    begin
                        SetValue(25);
                    end;
                }
                field(Field26; MATRIX_CellData[26])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[26];
                    Visible = Visible26;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[26] field';

                    trigger OnValidate()
                    begin
                        SetValue(26);
                    end;
                }
                field(Field27; MATRIX_CellData[27])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[27];
                    Visible = Visible27;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[27] field';

                    trigger OnValidate()
                    begin
                        SetValue(27);
                    end;
                }
                field(Field28; MATRIX_CellData[28])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[28];
                    Visible = Visible28;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[28] field';

                    trigger OnValidate()
                    begin
                        SetValue(28);
                    end;
                }
                field(Field29; MATRIX_CellData[29])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[29];
                    Visible = Visible29;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[29] field';

                    trigger OnValidate()
                    begin
                        SetValue(29);
                    end;
                }
                field(Field30; MATRIX_CellData[30])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[30];
                    Visible = Visible30;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[30] field';

                    trigger OnValidate()
                    begin
                        SetValue(30);
                    end;
                }
                field(Field31; MATRIX_CellData[31])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[31];
                    Visible = Visible31;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[31] field';

                    trigger OnValidate()
                    begin
                        SetValue(31);
                    end;
                }
                field(Field32; MATRIX_CellData[32])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[32];
                    Visible = Visible32;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[32] field';

                    trigger OnValidate()
                    begin
                        SetValue(32);
                    end;
                }
                field(Field33; MATRIX_CellData[33])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[33];
                    Visible = Visible33;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[33] field';

                    trigger OnValidate()
                    begin
                        SetValue(33);
                    end;
                }
                field(Field34; MATRIX_CellData[34])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[34];
                    Visible = Visible34;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[34] field';

                    trigger OnValidate()
                    begin
                        SetValue(34);
                    end;
                }
                field(Field35; MATRIX_CellData[35])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[35];
                    Visible = Visible35;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[35] field';

                    trigger OnValidate()
                    begin
                        SetValue(35);
                    end;
                }
                field(Field36; MATRIX_CellData[36])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[36];
                    Visible = Visible36;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[36] field';

                    trigger OnValidate()
                    begin
                        SetValue(36);
                    end;
                }
                field(Field37; MATRIX_CellData[37])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[37];
                    Visible = Visible37;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[37] field';

                    trigger OnValidate()
                    begin
                        SetValue(37);
                    end;
                }
                field(Field38; MATRIX_CellData[38])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[38];
                    Visible = Visible38;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[38] field';

                    trigger OnValidate()
                    begin
                        SetValue(38);
                    end;
                }
                field(Field39; MATRIX_CellData[39])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[39];
                    Visible = Visible39;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[39] field';

                    trigger OnValidate()
                    begin
                        SetValue(39);
                    end;
                }
                field(Field40; MATRIX_CellData[40])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[40];
                    Visible = Visible40;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[40] field';

                    trigger OnValidate()
                    begin
                        SetValue(40);
                    end;
                }
                field(Field41; MATRIX_CellData[41])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[41];
                    Visible = Visible41;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[41] field';

                    trigger OnValidate()
                    begin
                        SetValue(41);
                    end;
                }
                field(Field42; MATRIX_CellData[42])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[42];
                    Visible = Visible42;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[42] field';

                    trigger OnValidate()
                    begin
                        SetValue(42);
                    end;
                }
                field(Field43; MATRIX_CellData[43])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[43];
                    Visible = Visible43;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[43] field';

                    trigger OnValidate()
                    begin
                        SetValue(43);
                    end;
                }
                field(Field44; MATRIX_CellData[44])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[44];
                    Visible = Visible44;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[44] field';

                    trigger OnValidate()
                    begin
                        SetValue(44);
                    end;
                }
                field(Field45; MATRIX_CellData[45])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[45];
                    Visible = Visible45;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[45] field';

                    trigger OnValidate()
                    begin
                        SetValue(45);
                    end;
                }
                field(Field46; MATRIX_CellData[46])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[46];
                    Visible = Visible46;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[46] field';

                    trigger OnValidate()
                    begin
                        SetValue(46);
                    end;
                }
                field(Field47; MATRIX_CellData[47])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[47];
                    Visible = Visible47;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[47] field';

                    trigger OnValidate()
                    begin
                        SetValue(47);
                    end;
                }
                field(Field48; MATRIX_CellData[48])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[48];
                    Visible = Visible48;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[48] field';

                    trigger OnValidate()
                    begin
                        SetValue(48);
                    end;
                }
                field(Field49; MATRIX_CellData[49])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[49];
                    Visible = Visible49;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[49] field';

                    trigger OnValidate()
                    begin
                        SetValue(49);
                    end;
                }
                field(Field50; MATRIX_CellData[50])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[50];
                    Visible = Visible50;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[50] field';

                    trigger OnValidate()
                    begin
                        SetValue(50);
                    end;
                }
                field(Field51; MATRIX_CellData[51])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[51];
                    Visible = Visible51;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[51] field';

                    trigger OnValidate()
                    begin
                        SetValue(51);
                    end;
                }
                field(Field52; MATRIX_CellData[52])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[52];
                    Visible = Visible52;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[52] field';

                    trigger OnValidate()
                    begin
                        SetValue(52);
                    end;
                }
                field(Field53; MATRIX_CellData[53])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[53];
                    Visible = Visible53;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[53] field';

                    trigger OnValidate()
                    begin
                        SetValue(53);
                    end;
                }
                field(Field54; MATRIX_CellData[54])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[54];
                    Visible = Visible54;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[54] field';

                    trigger OnValidate()
                    begin
                        SetValue(54);
                    end;
                }
                field(Field55; MATRIX_CellData[55])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[55];
                    Visible = Visible55;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[55] field';

                    trigger OnValidate()
                    begin
                        SetValue(55);
                    end;
                }
                field(Field56; MATRIX_CellData[56])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[56];
                    Visible = Visible56;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[56] field';

                    trigger OnValidate()
                    begin
                        SetValue(56);
                    end;
                }
                field(Field57; MATRIX_CellData[57])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[57];
                    Visible = Visible57;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[57] field';

                    trigger OnValidate()
                    begin
                        SetValue(57);
                    end;
                }
                field(Field58; MATRIX_CellData[58])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[58];
                    Visible = Visible58;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[58] field';

                    trigger OnValidate()
                    begin
                        SetValue(58);
                    end;
                }
                field(Field59; MATRIX_CellData[59])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[59];
                    Visible = Visible59;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[59] field';

                    trigger OnValidate()
                    begin
                        SetValue(59);
                    end;
                }
                field(Field60; MATRIX_CellData[60])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[60];
                    Visible = Visible60;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[60] field';

                    trigger OnValidate()
                    begin
                        SetValue(60);
                    end;
                }
                field(Field61; MATRIX_CellData[61])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[61];
                    Visible = Visible61;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[61] field';

                    trigger OnValidate()
                    begin
                        SetValue(61);
                    end;
                }
                field(Field62; MATRIX_CellData[62])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[62];
                    Visible = Visible62;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[62] field';

                    trigger OnValidate()
                    begin
                        SetValue(62);
                    end;
                }
                field(Field63; MATRIX_CellData[63])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[63];
                    Visible = Visible63;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[63] field';

                    trigger OnValidate()
                    begin
                        SetValue(63);
                    end;
                }
                field(Field64; MATRIX_CellData[64])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[64];
                    Visible = Visible64;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[64] field';

                    trigger OnValidate()
                    begin
                        SetValue(64);
                    end;
                }
                field(Field65; MATRIX_CellData[65])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[65];
                    Visible = Visible65;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[65] field';

                    trigger OnValidate()
                    begin
                        SetValue(65);
                    end;
                }
                field(Field66; MATRIX_CellData[66])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[66];
                    Visible = Visible66;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[66] field';

                    trigger OnValidate()
                    begin
                        SetValue(66);
                    end;
                }
                field(Field67; MATRIX_CellData[67])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[67];
                    Visible = Visible67;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[67] field';

                    trigger OnValidate()
                    begin
                        SetValue(67);
                    end;
                }
                field(Field68; MATRIX_CellData[68])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[68];
                    Visible = Visible68;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[68] field';

                    trigger OnValidate()
                    begin
                        SetValue(68);
                    end;
                }
                field(Field69; MATRIX_CellData[69])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[69];
                    Visible = Visible69;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[69] field';

                    trigger OnValidate()
                    begin
                        SetValue(69);
                    end;
                }
                field(Field70; MATRIX_CellData[70])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[70];
                    Visible = Visible70;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[70] field';

                    trigger OnValidate()
                    begin
                        SetValue(70);
                    end;
                }
                field(Field71; MATRIX_CellData[71])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[71];
                    Visible = Visible71;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[71] field';

                    trigger OnValidate()
                    begin
                        SetValue(71);
                    end;
                }
                field(Field72; MATRIX_CellData[72])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[72];
                    Visible = Visible72;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[72] field';

                    trigger OnValidate()
                    begin
                        SetValue(72);
                    end;
                }
                field(Field73; MATRIX_CellData[73])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[73];
                    Visible = Visible73;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[73] field';

                    trigger OnValidate()
                    begin
                        SetValue(73);
                    end;
                }
                field(Field74; MATRIX_CellData[74])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[74];
                    Visible = Visible74;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[74] field';

                    trigger OnValidate()
                    begin
                        SetValue(74);
                    end;
                }
                field(Field75; MATRIX_CellData[75])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[75];
                    Visible = Visible75;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[75] field';

                    trigger OnValidate()
                    begin
                        SetValue(75);
                    end;
                }
                field(Field76; MATRIX_CellData[76])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[76];
                    Visible = Visible76;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[76] field';

                    trigger OnValidate()
                    begin
                        SetValue(76);
                    end;
                }
                field(Field77; MATRIX_CellData[77])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[77];
                    Visible = Visible77;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[77] field';

                    trigger OnValidate()
                    begin
                        SetValue(77);
                    end;
                }
                field(Field78; MATRIX_CellData[78])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[78];
                    Visible = Visible78;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[78] field';

                    trigger OnValidate()
                    begin
                        SetValue(78);
                    end;
                }
                field(Field79; MATRIX_CellData[79])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[79];
                    Visible = Visible79;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[79] field';

                    trigger OnValidate()
                    begin
                        SetValue(79);
                    end;
                }
                field(Field80; MATRIX_CellData[80])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[80];
                    Visible = Visible80;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[80] field';

                    trigger OnValidate()
                    begin
                        SetValue(80);
                    end;
                }
                field(Field81; MATRIX_CellData[81])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[81];
                    Visible = Visible81;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[81] field';

                    trigger OnValidate()
                    begin
                        SetValue(81);
                    end;
                }
                field(Field82; MATRIX_CellData[82])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[82];
                    Visible = Visible82;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[82] field';

                    trigger OnValidate()
                    begin
                        SetValue(82);
                    end;
                }
                field(Field83; MATRIX_CellData[83])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[83];
                    Visible = Visible83;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[83] field';

                    trigger OnValidate()
                    begin
                        SetValue(83);
                    end;
                }
                field(Field84; MATRIX_CellData[84])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[84];
                    Visible = Visible84;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[84] field';

                    trigger OnValidate()
                    begin
                        SetValue(84);
                    end;
                }
                field(Field85; MATRIX_CellData[85])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[85];
                    Visible = Visible85;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[85] field';

                    trigger OnValidate()
                    begin
                        SetValue(85);
                    end;
                }
                field(Field86; MATRIX_CellData[86])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[86];
                    Visible = Visible86;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[86] field';

                    trigger OnValidate()
                    begin
                        SetValue(86);
                    end;
                }
                field(Field87; MATRIX_CellData[87])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[87];
                    Visible = Visible87;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[87] field';

                    trigger OnValidate()
                    begin
                        SetValue(87);
                    end;
                }
                field(Field88; MATRIX_CellData[88])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[88];
                    Visible = Visible88;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[88] field';

                    trigger OnValidate()
                    begin
                        SetValue(88);
                    end;
                }
                field(Field89; MATRIX_CellData[89])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[89];
                    Visible = Visible89;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[89] field';

                    trigger OnValidate()
                    begin
                        SetValue(89);
                    end;
                }
                field(Field90; MATRIX_CellData[90])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[90];
                    Visible = Visible90;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[90] field';

                    trigger OnValidate()
                    begin
                        SetValue(90);
                    end;
                }
                field(Field91; MATRIX_CellData[91])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[91];
                    Visible = Visible91;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[91] field';

                    trigger OnValidate()
                    begin
                        SetValue(91);
                    end;
                }
                field(Field92; MATRIX_CellData[92])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[92];
                    Visible = Visible92;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[92] field';

                    trigger OnValidate()
                    begin
                        SetValue(92);
                    end;
                }
                field(Field93; MATRIX_CellData[93])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[93];
                    Visible = Visible93;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[93] field';

                    trigger OnValidate()
                    begin
                        SetValue(93);
                    end;
                }
                field(Field94; MATRIX_CellData[94])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[94];
                    Visible = Visible94;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[94] field';

                    trigger OnValidate()
                    begin
                        SetValue(94);
                    end;
                }
                field(Field95; MATRIX_CellData[95])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[95];
                    Visible = Visible95;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[95] field';

                    trigger OnValidate()
                    begin
                        SetValue(95);
                    end;
                }
                field(Field96; MATRIX_CellData[96])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[96];
                    Visible = Visible96;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[96] field';

                    trigger OnValidate()
                    begin
                        SetValue(96);
                    end;
                }
                field(Field97; MATRIX_CellData[97])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[97];
                    Visible = Visible97;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[97] field';

                    trigger OnValidate()
                    begin
                        SetValue(97);
                    end;
                }
                field(Field98; MATRIX_CellData[98])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[98];
                    Visible = Visible98;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[98] field';

                    trigger OnValidate()
                    begin
                        SetValue(98);
                    end;
                }
                field(Field99; MATRIX_CellData[99])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[99];
                    Visible = Visible99;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[99] field';

                    trigger OnValidate()
                    begin
                        SetValue(99);
                    end;
                }
                field(Field100; MATRIX_CellData[100])
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    CaptionClass = '3,' + MATRIX_CaptionSet[100];
                    Visible = Visible100;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[100] field';

                    trigger OnValidate()
                    begin
                        SetValue(100);
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
                    group(Control6150629)
                    {
                        ShowCaption = false;
                        field("Currently Showing"; CurrVRTField.Description)
                        {
                            ApplicationArea = All;
                            Caption = 'Currently Showing';
                            ToolTip = 'Specifies the value of the Currently Showing field';
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
                PromotedCategory = New;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Table Copy action';

                trigger OnAction()
                var
                    VRTCloneData: Codeunit "NPR Variety Clone Data";
                begin
                    VRTCloneData.CreateTableCopy(Item, 0, false);
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
            action("Select All")
            {
                Caption = 'Select All';
                Image = "Table";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Select All action';

                trigger OnAction()
                begin
                    //-NPR5.32 [274170]
                    VRTMatrixMgt.TickAllCombinations(CurrVRTField);
                    CurrPage.Update(false);
                    //+NPR5.32 [274170]
                end;
            }
            action("Select Active Row")
            {
                Caption = 'Select Active Row';
                Image = Line;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Select Active Row action';

                trigger OnAction()
                begin
                    //-NPR5.32 [274170]
                    VRTMatrixMgt.TickCurrentRow(CurrVRTField, Rec);
                    CurrPage.Update(false);
                    //+NPR5.32 [274170]
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
        MatrixRecords: array[100] of Record "NPR Variety Buffer" temporary;
        MatrixRecord: Record "NPR Variety Buffer" temporary;
        MATRIX_CurrentNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[100] of Boolean;
        Item: Record Item;
        ShowAsCrossVRT: Option Variety1,Variety2,Variety3,Variety4;
        RecRef: RecordRef;
        VRTMatrixMgt: Codeunit "NPR Variety Matrix Management";
        LocationFilter: Code[10];
        GD1: Code[10];
        GD2: Code[10];
        CurrVRTField: Record "NPR Variety Field Setup";
        ShowVariety1: Boolean;
        ShowVariety2: Boolean;
        ShowVariety3: Boolean;
        ShowVariety4: Boolean;
        MATRIX_MatrixRecords: array[100] of Record "NPR Variety Buffer" temporary;
        MATRIX_CaptionSet: array[100] of Text[1024];
        MATRIX_CaptionRange: Text[1024];
        MATRIX_PrimKeyFirstCaptionInCu: Text[1024];
        MATRIX_CurrentNoOfColumns: Integer;
        HideInactive: Boolean;
        Initialized: Boolean;
        [InDataSet]
        Visible1: Boolean;
        [InDataSet]
        Visible2: Boolean;
        [InDataSet]
        Visible3: Boolean;
        [InDataSet]
        Visible4: Boolean;
        [InDataSet]
        Visible5: Boolean;
        [InDataSet]
        Visible6: Boolean;
        [InDataSet]
        Visible7: Boolean;
        [InDataSet]
        Visible8: Boolean;
        [InDataSet]
        Visible9: Boolean;
        [InDataSet]
        Visible10: Boolean;
        [InDataSet]
        Visible11: Boolean;
        [InDataSet]
        Visible12: Boolean;
        [InDataSet]
        Visible13: Boolean;
        [InDataSet]
        Visible14: Boolean;
        [InDataSet]
        Visible15: Boolean;
        [InDataSet]
        Visible16: Boolean;
        [InDataSet]
        Visible17: Boolean;
        [InDataSet]
        Visible18: Boolean;
        [InDataSet]
        Visible19: Boolean;
        [InDataSet]
        Visible20: Boolean;
        [InDataSet]
        Visible21: Boolean;
        [InDataSet]
        Visible22: Boolean;
        [InDataSet]
        Visible23: Boolean;
        [InDataSet]
        Visible24: Boolean;
        [InDataSet]
        Visible25: Boolean;
        [InDataSet]
        Visible26: Boolean;
        [InDataSet]
        Visible27: Boolean;
        [InDataSet]
        Visible28: Boolean;
        [InDataSet]
        Visible29: Boolean;
        [InDataSet]
        Visible30: Boolean;
        [InDataSet]
        Visible31: Boolean;
        [InDataSet]
        Visible32: Boolean;
        [InDataSet]
        Visible33: Boolean;
        [InDataSet]
        Visible34: Boolean;
        [InDataSet]
        Visible35: Boolean;
        [InDataSet]
        Visible36: Boolean;
        [InDataSet]
        Visible37: Boolean;
        [InDataSet]
        Visible38: Boolean;
        [InDataSet]
        Visible39: Boolean;
        [InDataSet]
        Visible40: Boolean;
        [InDataSet]
        Visible41: Boolean;
        [InDataSet]
        Visible42: Boolean;
        [InDataSet]
        Visible43: Boolean;
        [InDataSet]
        Visible44: Boolean;
        [InDataSet]
        Visible45: Boolean;
        [InDataSet]
        Visible46: Boolean;
        [InDataSet]
        Visible47: Boolean;
        [InDataSet]
        Visible48: Boolean;
        [InDataSet]
        Visible49: Boolean;
        [InDataSet]
        Visible50: Boolean;
        [InDataSet]
        Visible51: Boolean;
        [InDataSet]
        Visible52: Boolean;
        [InDataSet]
        Visible53: Boolean;
        [InDataSet]
        Visible54: Boolean;
        [InDataSet]
        Visible55: Boolean;
        [InDataSet]
        Visible56: Boolean;
        [InDataSet]
        Visible57: Boolean;
        [InDataSet]
        Visible58: Boolean;
        [InDataSet]
        Visible59: Boolean;
        [InDataSet]
        Visible60: Boolean;
        [InDataSet]
        Visible61: Boolean;
        [InDataSet]
        Visible62: Boolean;
        [InDataSet]
        Visible63: Boolean;
        [InDataSet]
        Visible64: Boolean;
        [InDataSet]
        Visible65: Boolean;
        [InDataSet]
        Visible66: Boolean;
        [InDataSet]
        Visible67: Boolean;
        [InDataSet]
        Visible68: Boolean;
        [InDataSet]
        Visible69: Boolean;
        [InDataSet]
        Visible70: Boolean;
        [InDataSet]
        Visible71: Boolean;
        [InDataSet]
        Visible72: Boolean;
        [InDataSet]
        Visible73: Boolean;
        [InDataSet]
        Visible74: Boolean;
        [InDataSet]
        Visible75: Boolean;
        [InDataSet]
        Visible76: Boolean;
        [InDataSet]
        Visible77: Boolean;
        [InDataSet]
        Visible78: Boolean;
        [InDataSet]
        Visible79: Boolean;
        [InDataSet]
        Visible80: Boolean;
        [InDataSet]
        Visible81: Boolean;
        [InDataSet]
        Visible82: Boolean;
        [InDataSet]
        Visible83: Boolean;
        [InDataSet]
        Visible84: Boolean;
        [InDataSet]
        Visible85: Boolean;
        [InDataSet]
        Visible86: Boolean;
        [InDataSet]
        Visible87: Boolean;
        [InDataSet]
        Visible88: Boolean;
        [InDataSet]
        Visible89: Boolean;
        [InDataSet]
        Visible90: Boolean;
        [InDataSet]
        Visible91: Boolean;
        [InDataSet]
        Visible92: Boolean;
        [InDataSet]
        Visible93: Boolean;
        [InDataSet]
        Visible94: Boolean;
        [InDataSet]
        Visible95: Boolean;
        [InDataSet]
        Visible96: Boolean;
        [InDataSet]
        Visible97: Boolean;
        [InDataSet]
        Visible98: Boolean;
        [InDataSet]
        Visible99: Boolean;
        [InDataSet]
        Visible100: Boolean;

    local procedure Initialize()
    begin
        if Initialized then
            exit;

        VarietySetup.Get();
        VarietySetup.TestField("Variety Enabled", true);

        HideInactive := false;
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

    local procedure MATRIX_OnAfterGetRecord(MATRIX_ColumnOrdinal: Integer)
    var
        VRTBuffer: Record "NPR Variety Buffer" temporary;
        TMPBool: Boolean;
    begin
        MatrixRecord := MatrixRecords[MATRIX_ColumnOrdinal];

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
        TMPBool := VRTMatrixMgt.GetValueBool(VRTBuffer."Variety 1 Value", VRTBuffer."Variety 2 Value",
                                                VRTBuffer."Variety 3 Value", VRTBuffer."Variety 4 Value",
                                                CurrVRTField, LocationFilter, GD1, GD2);
        MATRIX_CellData[MATRIX_ColumnOrdinal] := TMPBool;
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

        SetVisible();

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
        //+NPR5.36 [285733]


        CurrPage.Update(false);
    end;

    procedure SetRecordRef(RecRef2: RecordRef; var Item2: Record Item; ShowFieldNo: Integer)
    begin
        RecRef := RecRef2;
        Item := Item2;
        LocationFilter := Item2.GetFilter("Location Filter");
        VRTMatrixMgt.SetRecord(RecRef2, Item."No.");
        //CurrVRTField.SETRANGE(Type, CurrVRTField.Type::Field);
        CurrVRTField.SetRange("Table No.", RecRef.Number);

        //-NPR5.32 [274170]
        if CurrVRTField.FindSet() then
            repeat
                if CurrVRTField.Type = CurrVRTField.Type::Field then begin
                    CurrVRTField.CalcFields("Field Type Name");
                    if CurrVRTField."Field Type Name" = 'Boolean' then
                        CurrVRTField.Mark(true);
                end else
                    CurrVRTField.Mark(true);
            until CurrVRTField.Next() = 0;
        CurrVRTField.MarkedOnly(true);
        //+NPR5.32 [274170]

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

    procedure SetValue(FieldNo: Integer): Text[250]
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
                VRT1Value := MATRIX_CaptionSet[FieldNo];
            ShowAsCrossVRT::Variety2:
                VRT2Value := MATRIX_CaptionSet[FieldNo];
            ShowAsCrossVRT::Variety3:
                VRT3Value := MATRIX_CaptionSet[FieldNo];
            ShowAsCrossVRT::Variety4:
                VRT4Value := MATRIX_CaptionSet[FieldNo];
        end;

        VRTMatrixMgt.SetValue(VRT1Value, VRT2Value, VRT3Value, VRT4Value, CurrVRTField, Format(MATRIX_CellData[FieldNo]));
        MATRIX_CellData[FieldNo] := VRTMatrixMgt.GetValueBool(VRT1Value, VRT2Value, VRT3Value, VRT4Value, CurrVRTField, LocationFilter, GD1, GD2);
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

    local procedure SetVisible()
    begin
        Visible1 := (MATRIX_CurrentNoOfColumns >= 1);
        Visible2 := (MATRIX_CurrentNoOfColumns >= 2);
        Visible3 := (MATRIX_CurrentNoOfColumns >= 3);
        Visible4 := (MATRIX_CurrentNoOfColumns >= 4);
        Visible5 := (MATRIX_CurrentNoOfColumns >= 5);
        Visible6 := (MATRIX_CurrentNoOfColumns >= 6);
        Visible7 := (MATRIX_CurrentNoOfColumns >= 7);
        Visible8 := (MATRIX_CurrentNoOfColumns >= 8);
        Visible9 := (MATRIX_CurrentNoOfColumns >= 9);
        Visible10 := (MATRIX_CurrentNoOfColumns >= 10);
        Visible11 := (MATRIX_CurrentNoOfColumns >= 11);
        Visible12 := (MATRIX_CurrentNoOfColumns >= 12);
        Visible13 := (MATRIX_CurrentNoOfColumns >= 13);
        Visible14 := (MATRIX_CurrentNoOfColumns >= 14);
        Visible15 := (MATRIX_CurrentNoOfColumns >= 15);
        Visible16 := (MATRIX_CurrentNoOfColumns >= 16);
        Visible17 := (MATRIX_CurrentNoOfColumns >= 17);
        Visible18 := (MATRIX_CurrentNoOfColumns >= 18);
        Visible19 := (MATRIX_CurrentNoOfColumns >= 19);
        Visible20 := (MATRIX_CurrentNoOfColumns >= 20);
        Visible21 := (MATRIX_CurrentNoOfColumns >= 21);
        Visible22 := (MATRIX_CurrentNoOfColumns >= 22);
        Visible23 := (MATRIX_CurrentNoOfColumns >= 23);
        Visible24 := (MATRIX_CurrentNoOfColumns >= 24);
        Visible25 := (MATRIX_CurrentNoOfColumns >= 25);
        Visible26 := (MATRIX_CurrentNoOfColumns >= 26);
        Visible27 := (MATRIX_CurrentNoOfColumns >= 27);
        Visible28 := (MATRIX_CurrentNoOfColumns >= 28);
        Visible29 := (MATRIX_CurrentNoOfColumns >= 29);
        Visible30 := (MATRIX_CurrentNoOfColumns >= 30);
        Visible31 := (MATRIX_CurrentNoOfColumns >= 31);
        Visible32 := (MATRIX_CurrentNoOfColumns >= 32);
        Visible33 := (MATRIX_CurrentNoOfColumns >= 33);
        Visible34 := (MATRIX_CurrentNoOfColumns >= 34);
        Visible35 := (MATRIX_CurrentNoOfColumns >= 35);
        Visible36 := (MATRIX_CurrentNoOfColumns >= 36);
        Visible37 := (MATRIX_CurrentNoOfColumns >= 37);
        Visible38 := (MATRIX_CurrentNoOfColumns >= 38);
        Visible39 := (MATRIX_CurrentNoOfColumns >= 39);
        Visible40 := (MATRIX_CurrentNoOfColumns >= 40);
        Visible41 := (MATRIX_CurrentNoOfColumns >= 41);
        Visible42 := (MATRIX_CurrentNoOfColumns >= 42);
        Visible43 := (MATRIX_CurrentNoOfColumns >= 43);
        Visible44 := (MATRIX_CurrentNoOfColumns >= 44);
        Visible45 := (MATRIX_CurrentNoOfColumns >= 45);
        Visible46 := (MATRIX_CurrentNoOfColumns >= 46);
        Visible47 := (MATRIX_CurrentNoOfColumns >= 47);
        Visible48 := (MATRIX_CurrentNoOfColumns >= 48);
        Visible49 := (MATRIX_CurrentNoOfColumns >= 49);
        Visible50 := (MATRIX_CurrentNoOfColumns >= 50);
        Visible51 := (MATRIX_CurrentNoOfColumns >= 51);
        Visible52 := (MATRIX_CurrentNoOfColumns >= 52);
        Visible53 := (MATRIX_CurrentNoOfColumns >= 53);
        Visible54 := (MATRIX_CurrentNoOfColumns >= 54);
        Visible55 := (MATRIX_CurrentNoOfColumns >= 55);
        Visible56 := (MATRIX_CurrentNoOfColumns >= 56);
        Visible57 := (MATRIX_CurrentNoOfColumns >= 57);
        Visible58 := (MATRIX_CurrentNoOfColumns >= 58);
        Visible59 := (MATRIX_CurrentNoOfColumns >= 59);
        Visible60 := (MATRIX_CurrentNoOfColumns >= 60);
        Visible61 := (MATRIX_CurrentNoOfColumns >= 61);
        Visible62 := (MATRIX_CurrentNoOfColumns >= 62);
        Visible63 := (MATRIX_CurrentNoOfColumns >= 63);
        Visible64 := (MATRIX_CurrentNoOfColumns >= 64);
        Visible65 := (MATRIX_CurrentNoOfColumns >= 65);
        Visible66 := (MATRIX_CurrentNoOfColumns >= 66);
        Visible67 := (MATRIX_CurrentNoOfColumns >= 67);
        Visible68 := (MATRIX_CurrentNoOfColumns >= 68);
        Visible69 := (MATRIX_CurrentNoOfColumns >= 69);
        Visible70 := (MATRIX_CurrentNoOfColumns >= 70);
        Visible71 := (MATRIX_CurrentNoOfColumns >= 71);
        Visible72 := (MATRIX_CurrentNoOfColumns >= 72);
        Visible73 := (MATRIX_CurrentNoOfColumns >= 73);
        Visible74 := (MATRIX_CurrentNoOfColumns >= 74);
        Visible75 := (MATRIX_CurrentNoOfColumns >= 75);
        Visible76 := (MATRIX_CurrentNoOfColumns >= 76);
        Visible77 := (MATRIX_CurrentNoOfColumns >= 77);
        Visible78 := (MATRIX_CurrentNoOfColumns >= 78);
        Visible79 := (MATRIX_CurrentNoOfColumns >= 79);
        Visible80 := (MATRIX_CurrentNoOfColumns >= 80);
        Visible81 := (MATRIX_CurrentNoOfColumns >= 81);
        Visible82 := (MATRIX_CurrentNoOfColumns >= 82);
        Visible83 := (MATRIX_CurrentNoOfColumns >= 83);
        Visible84 := (MATRIX_CurrentNoOfColumns >= 84);
        Visible85 := (MATRIX_CurrentNoOfColumns >= 85);
        Visible86 := (MATRIX_CurrentNoOfColumns >= 86);
        Visible87 := (MATRIX_CurrentNoOfColumns >= 87);
        Visible88 := (MATRIX_CurrentNoOfColumns >= 88);
        Visible89 := (MATRIX_CurrentNoOfColumns >= 89);
        Visible90 := (MATRIX_CurrentNoOfColumns >= 90);
        Visible91 := (MATRIX_CurrentNoOfColumns >= 91);
        Visible92 := (MATRIX_CurrentNoOfColumns >= 92);
        Visible93 := (MATRIX_CurrentNoOfColumns >= 93);
        Visible94 := (MATRIX_CurrentNoOfColumns >= 94);
        Visible95 := (MATRIX_CurrentNoOfColumns >= 95);
        Visible96 := (MATRIX_CurrentNoOfColumns >= 96);
        Visible97 := (MATRIX_CurrentNoOfColumns >= 97);
        Visible98 := (MATRIX_CurrentNoOfColumns >= 98);
        Visible99 := (MATRIX_CurrentNoOfColumns >= 99);
        Visible100 := (MATRIX_CurrentNoOfColumns >= 100);
    end;
}

