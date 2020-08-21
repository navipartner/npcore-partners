page 6060158 "Event Web Sales Setup"
{
    // NPR5.48/TJ  /20190124 CASE 263728 New object

    Caption = 'Event Web Sales Setup';
    PageType = List;
    SourceTable = "Event Web Sales Setup";
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
                field("No."; "No.")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        RetailItemList: Page "Retail Item List";
                        GLAccount: Record "G/L Account";
                    begin
                        case Type of
                            Type::Item:
                                begin
                                    RetailItemList.LookupMode := true;
                                    if "No." <> '' then begin
                                        Item.Get("No.");
                                        RetailItemList.SetRecord(Item);
                                    end;
                                    RetailItemList.SetTableView(Item);
                                    if RetailItemList.RunModal = ACTION::LookupOK then begin
                                        RetailItemList.GetRecord(Item);
                                        Validate("No.", Item."No.");
                                    end;
                                end;
                            Type::"G/L Account":
                                begin
                                    if "No." <> '' then
                                        GLAccount.Get("No.");
                                    if PAGE.RunModal(0, GLAccount) = ACTION::LookupOK then
                                        Validate("No.", GLAccount."No.");
                                end;
                        end;
                    end;
                }
                field("Event No."; "Event No.")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Job: Record Job;
                        EventList: Page "Event List";
                    begin
                        EventList.LookupMode := true;
                        if "Event No." <> '' then begin
                            Job.Get("Event No.");
                            EventList.SetRecord(Job);
                        end;
                        Job.SetRange("Event", true);
                        EventList.SetTableView(Job);
                        if EventList.RunModal = ACTION::LookupOK then begin
                            EventList.GetRecord(Job);
                            Validate("Event No.", Job."No.");
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
    }
}

