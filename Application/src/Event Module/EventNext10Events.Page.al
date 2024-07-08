page 6060166 "NPR Event Next 10 Events"
{
    Extensible = False;
    Caption = 'Next 10 Events';
    CardPageID = "NPR Event Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = Job;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6014410)
            {
                ShowCaption = false;
                field("GETFILTERS"; Rec.GetFilters)
                {

                    Caption = 'Filters';
                    ToolTip = 'Specifies the filter set on attributes.';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the number for the next 10 events.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description for the next 10 events.';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {

                    ToolTip = 'Specifies the Bill-to Customer No. for the next 10 events.';
                    ApplicationArea = NPRRetail;
                }
                field("Event Status"; Rec."NPR Event Status")
                {

                    ToolTip = 'Specifies the status for the next 10 events.';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the starting date for the next 10 events.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Amount"; Rec."NPR Total Amount")
                {

                    ToolTip = 'Specifies the total amount to be charged for the next 10 events.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(View)
            {
                Caption = 'View';
                Image = View;
                RunObject = Page "NPR Event Card";
                RunPageLink = "No." = FIELD("No.");
                RunPageMode = View;

                ToolTip = 'View filters which are already set on the specific attributes.';
                ApplicationArea = NPRRetail;
            }
            group("Select Filter")
            {
                Caption = 'Select Filter';
                Image = "Filter";
                action("Select Responsible Person")
                {
                    Caption = 'Select Responsible Person';
                    Image = JobResponsibility;

                    ToolTip = 'Select the responsible person.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Resource: Record Resource;
                        ResourceList: Page "Resource List";
                    begin
                        ResourceList.LookupMode := true;
                        if ResourceList.RunModal() = ACTION::LookupOK then begin
                            ResourceList.GetRecord(Resource);
                            Rec.SetRange("Person Responsible", Resource."No.");
                        end;
                    end;
                }
            }
            action("Clear Filter")
            {
                Caption = 'Clear Filter';
                Image = ClearFilter;

                ToolTip = 'Clear all filters.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.Reset();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        MaxNoOfEvents := 10;
        CreateList();
    end;

    var
        MaxNoOfEvents: Integer;

    local procedure CreateList()
    var
        Job: Record Job;
        JobCount: Integer;
    begin
        Job.SetCurrentKey("Starting Date");
        Rec.FilterGroup := 2;
        Job.SetRange("NPR Event", true);
        Job.SetFilter("Starting Date", '>=%1', WorkDate());
        Rec.FilterGroup := 0;
        if Job.FindSet() then
            repeat
                JobCount += 1;
                Rec := Job;
                Rec.Insert();
            until (Job.Next() = 0) or (JobCount = MaxNoOfEvents);
    end;
}

