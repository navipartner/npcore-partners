page 6059975 "NPR Variety Fields Setup"
{
    Extensible = false;
    Caption = 'Variety Fields Setup';
    ContextSensitiveHelpPage = 'docs/retail/integrations/explanation/varieties/';
    PageType = List;
    SourceTable = "NPR Variety Field Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the variety field setup';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the table number';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {
                    ToolTip = 'Specifies the field number of the selected table';
                    ApplicationArea = NPRRetail;
                }
                field(Disabled; Rec.Disabled)
                {
                    ToolTip = 'Specifies if this field number is disabled or not';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Matrix Subscriber 1"; Rec."Variety Matrix Subscriber 1")
                {
                    ToolTip = 'Specifies the first variety matrix subscriber of the variety field setup';
                    ApplicationArea = NPRRetail;
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ToolTip = 'Specifies the sort order for the variety fields';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the selected field';
                    ApplicationArea = NPRRetail;
                }
                field("Validate Field"; Rec."Validate Field")
                {
                    ToolTip = 'Specifies if the selected field should be validated or not';
                    ApplicationArea = NPRRetail;
                }
                field("Editable Field"; Rec."Editable Field")
                {
                    ToolTip = 'Specifies whether the selected field is editable or not.';
                    ApplicationArea = NPRRetail;
                }
                field("Is Table Default"; Rec."Is Table Default")
                {
                    ToolTip = 'Specifies if the table is default or not.';
                    ApplicationArea = NPRRetail;
                }
                field("Is Table Default Maintenance"; Rec."Is Table Default Maintenance")
                {
                    ToolTip = 'Specifies if this is the default value to be shown in the Maintenance Matrix';
                    ApplicationArea = NPRRetail;
                }
                field("Show Total Column"; Rec."Show Total Column")
                {
                    ToolTip = 'Specifies if the Total Column should be shown in the Matrix';
                    ApplicationArea = NPRRetail;
                }
                field("OnDrillDown Codeunit ID"; Rec."OnDrillDown Codeunit ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the OnDrillDown Codeunit ID for the selected field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Location Filter"; Rec."Use Location Filter")
                {

                    Visible = false;
                    ToolTip = 'Specifies if the location filter should be used or not';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 1 Filter"; Rec."Use Global Dim 1 Filter")
                {

                    Visible = false;
                    ToolTip = 'Specifies if the first global dimension should be used as a filter or not';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 2 Filter"; Rec."Use Global Dim 2 Filter")
                {

                    Visible = false;
                    ToolTip = 'Specifies if the second global dimension should be used as a filter or not';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Type"; Rec."Secondary Type")
                {
                    ToolTip = 'Specifies the secondary type of the variety field setup';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Table No."; Rec."Secondary Table No.")
                {
                    ToolTip = 'Specifies the secondary table number';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Field No."; Rec."Secondary Field No.")
                {
                    ToolTip = 'Specifies the secondary field number of the selected secondary table';
                    ApplicationArea = NPRRetail;
                }
                field("Variety Matrix Subscriber 2"; Rec."Variety Matrix Subscriber 2")
                {
                    ToolTip = 'Specifies the second variety matrix subscriber of the variety field setup';
                    ApplicationArea = NPRRetail;
                }
                field("Secondary Description"; Rec."Secondary Description")
                {
                    ToolTip = 'Specifies secondary field description of the secondary selected field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Location Filter (Sec)"; Rec."Use Location Filter (Sec)")
                {

                    Visible = false;
                    ToolTip = 'Specifies if the secondary location filter should be used or not';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 1 Filter (Sec)"; Rec."Use Global Dim 1 Filter (Sec)")
                {

                    Visible = false;
                    ToolTip = 'Specifies if the secondary first global dimension should be used as a filter or not';
                    ApplicationArea = NPRRetail;
                }
                field("Use Global Dim 2 Filter (Sec)"; Rec."Use Global Dim 2 Filter (Sec)")
                {

                    Visible = false;
                    ToolTip = 'Specifies if the secondary second global dimension should be used as a filter or not';
                    ApplicationArea = NPRRetail;
                }
                field("OnLookup Subscriber"; Rec."OnLookup Subscriber")
                {
                    ToolTip = 'Specifies the OnLookup Subscriber for the selected field';
                    ApplicationArea = NPRRetail;
                }
                field("Use OnLookup Return Value"; Rec."Use OnLookup Return Value")
                {
                    ToolTip = 'Specifies if the OnLookup Return Value should be used or not';
                    ApplicationArea = NPRRetail;
                }
                field("OnDrillDown Subscriber"; Rec."OnDrillDown Subscriber")
                {
                    ToolTip = 'Specifies if the OnDrillDown Subscriber should be used or not';
                    ApplicationArea = NPRRetail;
                }
                field("Use OnDrillDown Return Value"; Rec."Use OnDrillDown Return Value")
                {
                    ToolTip = 'Specifies if the OnDrillDown Return Value should be used or not';
                    ApplicationArea = NPRRetail;
                }
                field("Lookup Type"; Rec."Lookup Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the lookup type for the selected field';
                    ApplicationArea = NPRRetail;
                }
                field("Lookup Object No."; Rec."Lookup Object No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the object number used for the lookup';
                    ApplicationArea = NPRRetail;
                }
                field("Call Codeunit with rec"; Rec."Call Codeunit with rec")
                {

                    Visible = false;
                    ToolTip = 'Specifies if the Call Codeunit with record should be used or not';
                    ApplicationArea = NPRRetail;
                }
                field("Function Identifier"; Rec."Function Identifier")
                {

                    Visible = false;
                    ToolTip = 'Specifies the function identifier for the selected field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Type Name"; Rec."Field Type Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the name of the field type.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Insert Default Setup")
            {
                Caption = 'Insert Default Setup';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Insert the default setup on the variety fields setup table.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.InitVarietyFields();
                end;
            }
        }
    }
}

