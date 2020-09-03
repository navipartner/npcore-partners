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
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                }
                field("Variety Matrix Subscriber 1"; "Variety Matrix Subscriber 1")
                {
                    ApplicationArea = All;
                }
                field("Sort Order"; "Sort Order")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Validate Field"; "Validate Field")
                {
                    ApplicationArea = All;
                }
                field("Editable Field"; "Editable Field")
                {
                    ApplicationArea = All;
                }
                field("Is Table Default"; "Is Table Default")
                {
                    ApplicationArea = All;
                }
                field("OnDrillDown Codeunit ID"; "OnDrillDown Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Use Location Filter"; "Use Location Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Use Global Dim 1 Filter"; "Use Global Dim 1 Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Use Global Dim 2 Filter"; "Use Global Dim 2 Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Secondary Type"; "Secondary Type")
                {
                    ApplicationArea = All;
                }
                field("Secondary Table No."; "Secondary Table No.")
                {
                    ApplicationArea = All;
                }
                field("Secondary Field No."; "Secondary Field No.")
                {
                    ApplicationArea = All;
                }
                field("Variety Matrix Subscriber 2"; "Variety Matrix Subscriber 2")
                {
                    ApplicationArea = All;
                }
                field("Secondary Description"; "Secondary Description")
                {
                    ApplicationArea = All;
                }
                field("Use Location Filter (Sec)"; "Use Location Filter (Sec)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Use Global Dim 1 Filter (Sec)"; "Use Global Dim 1 Filter (Sec)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Use Global Dim 2 Filter (Sec)"; "Use Global Dim 2 Filter (Sec)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("OnLookup Subscriber"; "OnLookup Subscriber")
                {
                    ApplicationArea = All;
                }
                field("Use OnLookup Return Value"; "Use OnLookup Return Value")
                {
                    ApplicationArea = All;
                }
                field("OnDrillDown Subscriber"; "OnDrillDown Subscriber")
                {
                    ApplicationArea = All;
                }
                field("Use OnDrillDown Return Value"; "Use OnDrillDown Return Value")
                {
                    ApplicationArea = All;
                }
                field("Lookup Type"; "Lookup Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Lookup Object No."; "Lookup Object No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Call Codeunit with rec"; "Call Codeunit with rec")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Function Identifier"; "Function Identifier")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Field Type Name"; "Field Type Name")
                {
                    ApplicationArea = All;
                    Visible = false;
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

                trigger OnAction()
                begin
                    InitVarietyFields;
                end;
            }
        }
    }
}

