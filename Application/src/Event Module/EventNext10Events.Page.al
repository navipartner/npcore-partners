page 6060166 "NPR Event Next 10 Events"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.32/TJ  /20170523 CASE 277397 Added Image property to all actions missing it

    Caption = 'Next 10 Events';
    CardPageID = "NPR Event Card";
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Job;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6014410)
            {
                ShowCaption = false;
                field("GETFILTERS"; GetFilters)
                {
                    ApplicationArea = All;
                    Caption = 'Filters';
                    ToolTip = 'Specifies the value of the Filters field';
                }
            }
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                }
                field("Event Status"; "NPR Event Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Event Status field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Total Amount"; "NPR Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Total Amount field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the View action';
            }
            group("Select Filter")
            {
                Caption = 'Select Filter';
                Image = "Filter";
                action("Select Responsible Person")
                {
                    Caption = 'Select Responsible Person';
                    Image = JobResponsibility;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Select Responsible Person action';

                    trigger OnAction()
                    var
                        Resource: Record Resource;
                        ResourceList: Page "Resource List";
                    begin
                        ResourceList.LookupMode := true;
                        if ResourceList.RunModal = ACTION::LookupOK then begin
                            ResourceList.GetRecord(Resource);
                            //  PersonResponsible := Resource."No.";
                            //  PersonResponsibleName := Resource.Name;
                            SetRange("Person Responsible", Resource."No.");
                        end;
                    end;
                }
            }
            action("Clear Filter")
            {
                Caption = 'Clear Filter';
                Image = ClearFilter;
                ApplicationArea = All;
                ToolTip = 'Executes the Clear Filter action';

                trigger OnAction()
                begin
                    Reset;
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
        PersonResponsible: Code[10];
        PersonResponsibleName: Text;
        MaxNoOfEvents: Integer;
        Filters: Text;

    local procedure CreateList()
    var
        Job: Record Job;
        JobCount: Integer;
    begin
        Job.SetCurrentKey("Starting Date");
        FilterGroup := 2;
        Job.SetRange("NPR Event", true);
        Job.SetFilter("Starting Date", '>=%1', WorkDate);
        FilterGroup := 0;
        if Job.FindSet then
            repeat
                JobCount += 1;
                Rec := Job;
                Rec.Insert;
            until (Job.Next = 0) or (JobCount = MaxNoOfEvents);
    end;
}

