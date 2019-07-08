page 6060166 "Event Next 10 Events"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.32/TJ  /20170523 CASE 277397 Added Image property to all actions missing it

    Caption = 'Next 10 Events';
    CardPageID = "Event Card";
    Editable = false;
    PageType = ListPart;
    SourceTable = Job;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control6014410)
            {
                ShowCaption = false;
                field(GETFILTERS;GetFilters)
                {
                    Caption = 'Filters';
                }
            }
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Bill-to Customer No.";"Bill-to Customer No.")
                {
                }
                field("Event Status";"Event Status")
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Total Amount";"Total Amount")
                {
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
                RunObject = Page "Event Card";
                RunPageLink = "No."=FIELD("No.");
                RunPageMode = View;
            }
            group("Select Filter")
            {
                Caption = 'Select Filter';
                Image = "Filter";
                action("Select Responsible Person")
                {
                    Caption = 'Select Responsible Person';
                    Image = JobResponsibility;

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
                          SetRange("Person Responsible",Resource."No.");
                        end;
                    end;
                }
            }
            action("Clear Filter")
            {
                Caption = 'Clear Filter';
                Image = ClearFilter;

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
        Job.SetRange("Event",true);
        Job.SetFilter("Starting Date",'>=%1',WorkDate);
        FilterGroup := 0;
        if Job.FindSet then
          repeat
            JobCount += 1;
            Rec := Job;
            Rec.Insert;
          until (Job.Next = 0) or (JobCount = MaxNoOfEvents);
    end;
}

