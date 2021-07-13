page 6060054 "NPR Item Worksh. Field Setup"
{
    Caption = 'Item Worksheet Field Setup';
    PageType = List;
    SourceTable = "NPR Item Worksh. Field Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name"; Rec."Worksheet Template Name")
                {

                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {

                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Field Number"; Rec."Field Number")
                {

                    ToolTip = 'Specifies the value of the Field Number field.';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Field Caption"; Rec."Field Caption")
                {

                    ToolTip = 'Specifies the value of the Field Caption field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Number Create"; Rec."Target Field Number Create")
                {

                    ToolTip = 'Specifies the value of the Target Field Number Create field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Name Create"; Rec."Target Field Name Create")
                {

                    ToolTip = 'Specifies the value of the Target Field Name Create field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Caption Create"; Rec."Target Field Caption Create")
                {

                    ToolTip = 'Specifies the value of the Target Field Caption Create field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Number Update"; Rec."Target Field Number Update")
                {

                    ToolTip = 'Specifies the value of the Target Field Number Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Name Update"; Rec."Target Field Name Update")
                {

                    ToolTip = 'Specifies the value of the Target Field Name Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Target Field Caption Update"; Rec."Target Field Caption Update")
                {

                    ToolTip = 'Specifies the value of the Target Field Caption Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Process Create"; Rec."Process Create")
                {

                    ToolTip = 'Specifies the value of the Process Create field.';
                    ApplicationArea = NPRRetail;
                }
                field("Process Update"; Rec."Process Update")
                {

                    ToolTip = 'Specifies the value of the Process Update field.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Value for Create"; Rec."Default Value for Create")
                {

                    ToolTip = 'Specifies the value of the Default Value for Create field.';
                    ApplicationArea = NPRRetail;
                }
                field("Mapped Values"; Rec."Mapped Values")
                {

                    ToolTip = 'Specifies the value of the Mapped Values field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Field Value Map")
            {

                Caption = 'Field Value Map';
                Image = MapDimensions;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Item Worksh. Field Mapping";
                RunPageLink = "Worksheet Template Name" = FIELD("Worksheet Template Name"),
                              "Worksheet Name" = FIELD("Worksheet Name"),
                              "Table No." = FIELD("Table No."),
                              "Field Number" = FIELD("Field Number");
                RunPageView = SORTING("Worksheet Template Name", "Worksheet Name", "Table No.", "Field Number", "Source Value")
                              ORDER(Ascending);
                ToolTip = 'Executes the Field Value Map action.';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table No." := xRec."Table No.";
        Rec."Target Table No. Create" := xRec."Target Table No. Create";
        Rec."Target Table No. Update" := xRec."Target Table No. Update";
    end;
}

