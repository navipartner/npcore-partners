page 6060158 "NPR Event Web Sales Setup"
{
    Extensible = False;
    Caption = 'Event Web Sales Setup';
    PageType = List;
    SourceTable = "NPR Event Web Sales Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        RetailItemList: Page "Item List";
                        GLAccount: Record "G/L Account";
                    begin
                        case Rec.Type of
                            Rec.Type::Item:
                                begin
                                    RetailItemList.LookupMode := true;
                                    if Rec."No." <> '' then begin
                                        Item.Get(Rec."No.");
                                        RetailItemList.SetRecord(Item);
                                    end;
                                    RetailItemList.SetTableView(Item);
                                    if RetailItemList.RunModal() = ACTION::LookupOK then begin
                                        RetailItemList.GetRecord(Item);
                                        Rec.Validate("No.", Item."No.");
                                    end;
                                end;
                            Rec.Type::"G/L Account":
                                begin
                                    if Rec."No." <> '' then
                                        GLAccount.Get(Rec."No.");
                                    if PAGE.RunModal(0, GLAccount) = ACTION::LookupOK then
                                        Rec.Validate("No.", GLAccount."No.");
                                end;
                        end;
                    end;
                }
                field("Event No."; Rec."Event No.")
                {

                    ToolTip = 'Specifies the value of the Event No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Job: Record Job;
                        EventList: Page "NPR Event List";
                    begin
                        EventList.LookupMode := true;
                        if Rec."Event No." <> '' then begin
                            Job.Get(Rec."Event No.");
                            EventList.SetRecord(Job);
                        end;
                        Job.SetRange("NPR Event", true);
                        EventList.SetTableView(Job);
                        if EventList.RunModal() = ACTION::LookupOK then begin
                            EventList.GetRecord(Job);
                            Rec.Validate("Event No.", Job."No.");
                        end;
                    end;
                }
            }
        }
    }
}

