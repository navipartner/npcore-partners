page 6151582 "Event Events by Attributes"
{
    // NPR5.33/TJ  /20170628 CASE 277946 New object created
    // NPR5.38/TJ  /20171023 CASE 291965 Added View action

    Caption = 'Events by Attributes';
    CardPageID = "Event Card";
    Editable = false;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = Job;

    layout
    {
        area(content)
        {
            group(Control6014408)
            {
                ShowCaption = false;
                field(FilterDescription;FilterDescription)
                {
                    Caption = 'Attributes Filter';
                    Editable = false;
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
            action(SelectAttributeFilter)
            {
                Caption = 'Select Attribute Filter';
                Image = "Filter";

                trigger OnAction()
                var
                    EventAttributeTempFilters: Page "Event Attribute Temp. Filters";
                    EventAttributeTempFilter: Record "Event Attribute Temp. Filter";
                    EventAttrMgt: Codeunit "Event Attribute Management";
                    Job: Record Job;
                begin
                    EventAttributeTempFilters.LookupMode := true;
                    if EventAttributeTempFilters.RunModal = ACTION::LookupOK then begin
                      Reset;
                      EventAttributeTempFilters.GetRecord(EventAttributeTempFilter);
                      FilterDescription := EventAttributeTempFilter.Description;
                      if not EventAttrMgt.FindEventsInAttributesFilter(EventAttributeTempFilter."Template Name",EventAttributeTempFilter."Filter Name",Job) then
                        SetDefaultFilter()
                      else begin
                        Copy(Job);
                        MarkedOnly(true);
                      end;
                      CurrPage.Update(false);
                    end;
                end;
            }
            action(ClearFilter)
            {
                Caption = 'Clear Filter';
                Image = ClearFilter;

                trigger OnAction()
                begin
                    SetDefaultFilter();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetDefaultFilter;
    end;

    var
        FilterDescription: Text;

    local procedure SetDefaultFilter()
    begin
        SetRange("No.",'%$');
    end;
}

