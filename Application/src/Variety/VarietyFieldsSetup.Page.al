page 6059975 "NPR Variety Fields Setup"
{
    // VRT1.11/JDH /20160602 CASE 242940 Added Image to action
    // NPR5.28/JDH /20161128 CASE 255961 Added OnDrillDown Codeunit Id
    // NPR5.32/JDH /20170510 CASE 274170 Field Type Name Added
    // NPR5.47/NPKNAV/20181026  CASE 327541-01 Transport NPR5.47 - 26 October 2018

    Caption = 'Variety Fields Setup';
    PageType = List;
    SourceTable = "NPR Variety Field Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disabled field';
                }
                field("Variety Matrix Subscriber 1"; "Variety Matrix Subscriber 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Matrix Subscriber 1 field';
                }
                field("Sort Order"; "Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sort Order field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Validate Field"; "Validate Field")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Field field';
                }
                field("Editable Field"; "Editable Field")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Editable Field field';
                }
                field("Is Table Default"; "Is Table Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Table Default field';
                }
                field("OnDrillDown Codeunit ID"; "OnDrillDown Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the OnDrillDown Codeunit ID field';
                }
                field("Use Location Filter"; "Use Location Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Location Filter field';
                }
                field("Use Global Dim 1 Filter"; "Use Global Dim 1 Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 1 Filter field';
                }
                field("Use Global Dim 2 Filter"; "Use Global Dim 2 Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 2 Filter field';
                }
                field("Secondary Type"; "Secondary Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Secondary Type field';
                }
                field("Secondary Table No."; "Secondary Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Secondary Table No. field';
                }
                field("Secondary Field No."; "Secondary Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Secondary Field No. field';
                }
                field("Variety Matrix Subscriber 2"; "Variety Matrix Subscriber 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Matrix Subscriber 2 field';
                }
                field("Secondary Description"; "Secondary Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Secondary Field Description field';
                }
                field("Use Location Filter (Sec)"; "Use Location Filter (Sec)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Location Filter (Sec) field';
                }
                field("Use Global Dim 1 Filter (Sec)"; "Use Global Dim 1 Filter (Sec)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 1 Filter (Sec) field';
                }
                field("Use Global Dim 2 Filter (Sec)"; "Use Global Dim 2 Filter (Sec)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Use Global Dim 2 Filter (Sec) field';
                }
                field("OnLookup Subscriber"; "OnLookup Subscriber")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OnLookup Subscriber field';
                }
                field("Use OnLookup Return Value"; "Use OnLookup Return Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use OnLookup Return Value field';
                }
                field("OnDrillDown Subscriber"; "OnDrillDown Subscriber")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OnDrillDown Subscriber field';
                }
                field("Use OnDrillDown Return Value"; "Use OnDrillDown Return Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use OnDrillDown Return Value field';
                }
                field("Lookup Type"; "Lookup Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Lookup Type field';
                }
                field("Lookup Object No."; "Lookup Object No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Lookup Object No. field';
                }
                field("Call Codeunit with rec"; "Call Codeunit with rec")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Call Codeunit with rec field';
                }
                field("Function Identifier"; "Function Identifier")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Function Identifier field';
                }
                field("Field Type Name"; "Field Type Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Field Type Name field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Insert Default Setup action';

                trigger OnAction()
                begin
                    InitVarietyFields;
                end;
            }
        }
    }
}

