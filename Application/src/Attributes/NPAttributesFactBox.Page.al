page 6014465 "NPR NP Attributes FactBox"
{
    // NPR4.15/TS/20151013 CASE 224751 Created NpAttribute Factbox
    // NPR4.21/TS/20160225  CASE 224751 Open Retail Item Card Instead of Item Card
    // NPR5.29/LS  /20161108 CASE 257874 Changed length from 100 to 250 for Global Var "NPRAttrTextArray"
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes

    Caption = 'NP Attributes FactBox';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
                Caption = 'Item No.';
                ToolTip = 'Specifies the value of the Item No. field';

                trigger OnDrillDown()
                begin
                    ShowDetails();
                end;
            }
            field(NPRAttrTextArray_01; NPRAttrTextArray[1])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 1, Rec."No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 2, Rec."No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 3, Rec."No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 4, Rec."No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 5, Rec."No.", NPRAttrTextArray[5]);
                end;
            }
            field(NPRAttrTextArray_06; NPRAttrTextArray[6])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,6,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible06;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 6, Rec."No.", NPRAttrTextArray[6]);
                end;
            }
            field(NPRAttrTextArray_07; NPRAttrTextArray[7])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,7,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible07;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 7, Rec."No.", NPRAttrTextArray[7]);
                end;
            }
            field(NPRAttrTextArray_08; NPRAttrTextArray[8])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,8,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible08;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 8, Rec."No.", NPRAttrTextArray[8]);
                end;
            }
            field(NPRAttrTextArray_09; NPRAttrTextArray[9])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,9,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible09;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 9, Rec."No.", NPRAttrTextArray[9]);
                end;
            }
            field(NPRAttrTextArray_10; NPRAttrTextArray[10])
            {
                ApplicationArea = All;
                CaptionClass = '6014555,27,10,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible10;
                ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetMasterDataAttributeValue(DATABASE::Item, 10, Rec."No.", NPRAttrTextArray[10]);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        NPRAttrManagement.GetMasterDataAttributeValue(NPRAttrTextArray, DATABASE::Item, Rec."No.");
        NPRAttrEditable := CurrPage.Editable();
    end;

    trigger OnOpenPage()
    begin
        NPRAttrManagement.GetAttributeVisibility(DATABASE::Item, NPRAttrVisibleArray);
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
        NPRAttrTextArray: array[40] of Text[250];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
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

    procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Item Card", Rec);
    end;
}

