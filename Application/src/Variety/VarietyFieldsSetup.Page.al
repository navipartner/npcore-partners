page 6059975 "NPR Variety Fields Setup"
{
    Extensible = False;
    // VRT1.11/JDH /20160602 CASE 242940 Added Image to action
    // NPR5.28/JDH /20161128 CASE 255961 Added OnDrillDown Codeunit Id
    // NPR5.32/JDH /20170510 CASE 274170 Field Type Name Added
    // NPR5.47/NPKNAV/20181026  CASE 327541-01 Transport NPR5.47 - 26 October 2018

    Caption = 'Variety Fields Setup';
    PageType = List;
    SourceTable = "NPR Variety Field Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Disabled; Rec.Disabled)
                {

                    ToolTip = 'Specifies the value of the Disabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Matrix Subscriber 1"; Rec."Variety Matrix Subscriber 1")
                {

                    ToolTip = 'Specifies the value of the Variety Matrix Subscriber 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Sort Order"; Rec."Sort Order")
                {

                    ToolTip = 'Specifies the value of the Sort Order field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Validate Field"; Rec."Validate Field")
                {

                    ToolTip = 'Specifies the value of the Validate Field field';
                    ApplicationArea = NPRRetail;
                }
                field("Editable Field"; Rec."Editable Field")
                {

                    ToolTip = 'Specifies the value of the Editable Field field';
                    ApplicationArea = NPRRetail;
                }
                field("Is Table Default"; Rec."Is Table Default")
                {

                    ToolTip = 'Specifies the value of the Is Table Default field';
                    ApplicationArea = NPRRetail;
                }
                field("OnDrillDown Codeunit ID"; Rec."OnDrillDown Codeunit ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the OnDrillDown Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Location Filter"; Rec."Use Location Filter")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Location Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 1 Filter"; Rec."Use Global Dim 1 Filter")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 1 Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 2 Filter"; Rec."Use Global Dim 2 Filter")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 2 Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Type"; Rec."Secondary Type")
                {

                    ToolTip = 'Specifies the value of the Secondary Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Table No."; Rec."Secondary Table No.")
                {

                    ToolTip = 'Specifies the value of the Secondary Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Field No."; Rec."Secondary Field No.")
                {

                    ToolTip = 'Specifies the value of the Secondary Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Matrix Subscriber 2"; Rec."Variety Matrix Subscriber 2")
                {

                    ToolTip = 'Specifies the value of the Variety Matrix Subscriber 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Description"; Rec."Secondary Description")
                {

                    ToolTip = 'Specifies the value of the Secondary Field Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Location Filter (Sec)"; Rec."Use Location Filter (Sec)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Location Filter (Sec) field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 1 Filter (Sec)"; Rec."Use Global Dim 1 Filter (Sec)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 1 Filter (Sec) field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 2 Filter (Sec)"; Rec."Use Global Dim 2 Filter (Sec)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 2 Filter (Sec) field';
                    ApplicationArea = NPRRetail;
                }
                field("OnLookup Subscriber"; Rec."OnLookup Subscriber")
                {

                    ToolTip = 'Specifies the value of the OnLookup Subscriber field';
                    ApplicationArea = NPRRetail;
                }
                field("Use OnLookup Return Value"; Rec."Use OnLookup Return Value")
                {

                    ToolTip = 'Specifies the value of the Use OnLookup Return Value field';
                    ApplicationArea = NPRRetail;
                }
                field("OnDrillDown Subscriber"; Rec."OnDrillDown Subscriber")
                {

                    ToolTip = 'Specifies the value of the OnDrillDown Subscriber field';
                    ApplicationArea = NPRRetail;
                }
                field("Use OnDrillDown Return Value"; Rec."Use OnDrillDown Return Value")
                {

                    ToolTip = 'Specifies the value of the Use OnDrillDown Return Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Lookup Type"; Rec."Lookup Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Lookup Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Lookup Object No."; Rec."Lookup Object No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Lookup Object No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Call Codeunit with rec"; Rec."Call Codeunit with rec")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Call Codeunit with rec field';
                    ApplicationArea = NPRRetail;
                }
                field("Function Identifier"; Rec."Function Identifier")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Function Identifier field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Type Name"; Rec."Field Type Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Field Type Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Insert Default Setup")
            {
                Caption = 'Insert Default Setup';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Insert Default Setup action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.InitVarietyFields();
                end;
            }
        }
    }
}

