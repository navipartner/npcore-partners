page 6060052 "NPR Item Worksh. Attr. FactBox"
{
    Caption = 'NP Attributes FactBox';
    PageType = CardPart;
    SourceTable = "NPR Item Worksheet Line";
    layout
    {
        area(content)
        {
            field(NPRAttrTextArray_01; NPRAttrTextArray[1])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,1,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field.';
                Visible = NPRAttrVisible01;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 1, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRExItemAttrTextArray_01; NPRExItemAttrTextArray[1])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[1];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[1] field.';
                Visible = NPRAttrVisible01;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,2,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field.';
                Visible = NPRAttrVisible02;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 2, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRExItemAttrTextArray_02; NPRExItemAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[2];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[2] field.';
                Visible = NPRAttrVisible02;
            }
            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,3,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field.';
                Visible = NPRAttrVisible03;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 3, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRExItemAttrTextArray_03; NPRExItemAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[3];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[3] field.';
                Visible = NPRAttrVisible03;
            }
            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,4,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field.';
                Visible = NPRAttrVisible04;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 4, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRExItemAttrTextArray_04; NPRExItemAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[4];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[4] field.';
                Visible = NPRAttrVisible04;
            }
            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,5,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field.';
                Visible = NPRAttrVisible05;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 5, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[5]);
                end;
            }
            field(NPRExItemAttrTextArray_05; NPRExItemAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[5];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[5] field.';
                Visible = NPRAttrVisible05;
            }
            field(NPRAttrTextArray_06; NPRAttrTextArray[6])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,6,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field.';
                Visible = NPRAttrVisible06;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 6, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[6]);
                end;
            }
            field(NPRExItemAttrTextArray_06; NPRExItemAttrTextArray[6])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[6];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[6] field.';
                Visible = NPRAttrVisible06;
            }
            field(NPRAttrTextArray_07; NPRAttrTextArray[7])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,7,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field.';
                Visible = NPRAttrVisible07;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 7, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[7]);
                end;
            }
            field(NPRExItemAttrTextArray_07; NPRExItemAttrTextArray[7])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[7];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[7] field.';
                Visible = NPRAttrVisible07;
            }
            field(NPRAttrTextArray_08; NPRAttrTextArray[8])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,8,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field.';
                Visible = NPRAttrVisible08;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 8, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[8]);
                end;
            }
            field(NPRExItemAttrTextArray_08; NPRExItemAttrTextArray[8])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[8];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[8] field.';
                Visible = NPRAttrVisible08;
            }
            field(NPRAttrTextArray_09; NPRAttrTextArray[9])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,9,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field.';
                Visible = NPRAttrVisible09;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 9, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[9]);
                end;
            }
            field(NPRExItemAttrTextArray_09; NPRExItemAttrTextArray[9])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[9];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[9] field.';
                Visible = NPRAttrVisible09;
            }
            field(NPRAttrTextArray_10; NPRAttrTextArray[10])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,10,2';
                Editable = NPRAttrEditable;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field.';
                Visible = NPRAttrVisible10;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetWorksheetLineAttributeValue(
                        DATABASE::"NPR Item Worksheet Line", 10, Rec."Worksheet Template Name",
                        Rec."Worksheet Name", Rec."Line No.", NPRAttrTextArray[10]);
                end;
            }
            field(NPRExItemAttrTextArray_10; NPRExItemAttrTextArray[10])
            {
                ApplicationArea = All;
                CaptionClass = ExItemCaptionDim[10];
                Editable = false;
                Style = Attention;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the value of the NPRExItemAttrTextArray[10] field.';
                Visible = NPRAttrVisible10;
            }
        }
    }


    trigger OnAfterGetRecord()
    var
        i: Integer;
        ExItemLbl: Label 'Existing Item:';
    begin
        NPRAttrManagement.GetWorksheetLineAttributeValue(
            NPRAttrTextArray, DATABASE::"NPR Item Worksheet Line",
            Rec."Worksheet Template Name", Rec."Worksheet Name", Rec."Line No.");
        if (Rec."Existing Item No." <> '') then
            NPRAttrManagement.GetMasterDataAttributeValue(NPRExItemAttrTextArray, DATABASE::Item, Rec."Existing Item No.")
        else
            Clear(NPRExItemAttrTextArray);

        for i := 1 to 10 do begin
            if (NPRExItemAttrTextArray[i] <> NPRAttrTextArray[i]) and (Rec."Existing Item No." <> '') then
                ExItemCaptionDim[i] := ExItemLbl
            else begin
                NPRExItemAttrTextArray[i] := '';
                ExItemCaptionDim[i] := '';
            end
        end;

        NPRAttrEditable := CurrPage.Editable();
    end;

    trigger OnOpenPage()
    begin
        NPRAttrManagement.GetAttributeVisibility(DATABASE::"NPR Item Worksheet Line", NPRAttrVisibleArray);
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];

        NPRAttrEditable := CurrPage.Editable()
    end;

    var
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        ExItemCaptionDim: array[20] of Text[20];
        NPRAttrTextArray: array[40] of Text[100];
        NPRExItemAttrTextArray: array[40] of Text[100];

    procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Item Card", Rec);
    end;
}

