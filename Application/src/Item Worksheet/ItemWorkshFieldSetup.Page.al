page 6060054 "NPR Item Worksh. Field Setup"
{
    Caption = 'Item Worksheet Field Setup';
    PageType = List;
    SourceTable = "NPR Item Worksh. Field Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Worksheet Template Name"; Rec."Worksheet Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Journal Template Name field.';
                }
                field("Worksheet Name"; Rec."Worksheet Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Field Number"; Rec."Field Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Number field.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field.';
                }
                field("Target Field Number Create"; Rec."Target Field Number Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Number Create field.';
                }
                field("Target Field Name Create"; Rec."Target Field Name Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Name Create field.';
                }
                field("Target Field Caption Create"; Rec."Target Field Caption Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Caption Create field.';
                }
                field("Target Field Number Update"; Rec."Target Field Number Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Number Update field.';
                }
                field("Target Field Name Update"; Rec."Target Field Name Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Name Update field.';
                }
                field("Target Field Caption Update"; Rec."Target Field Caption Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Field Caption Update field.';
                }
                field("Process Create"; Rec."Process Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process Create field.';
                }
                field("Process Update"; Rec."Process Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process Update field.';
                }
                field("Default Value for Create"; Rec."Default Value for Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Value for Create field.';
                }
                field("Mapped Values"; Rec."Mapped Values")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mapped Values field.';
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
                ApplicationArea = All;
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
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Table No." := xRec."Table No.";
        "Target Table No. Create" := xRec."Target Table No. Create";
        "Target Table No. Update" := xRec."Target Table No. Update";
    end;
}

