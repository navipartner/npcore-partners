page 6150664 "NPR NPRE Seating List"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.36/ANEN/20170918 CASE 290639 Adding column seating location
    // NPR5.53/ALPO/20191210 CASE 380609 Dimensions: NPRE Seating integration
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Seating List';
    CardPageID = "NPR NPRE Seating";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Seating";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Seating Location"; "Seating Location")
                {
                    ApplicationArea = All;
                }
                field(Capacity; Capacity)
                {
                    ApplicationArea = All;
                }
                field("Fixed Capasity"; "Fixed Capasity")
                {
                    ApplicationArea = All;
                }
                field("Current Waiter Pad FF"; "Current Waiter Pad FF")
                {
                    ApplicationArea = All;
                }
                field("Current Waiter Pad Description"; "Current Waiter Pad Description")
                {
                    ApplicationArea = All;
                }
                field("Multiple Waiter Pad FF"; "Multiple Waiter Pad FF")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Seating)
            {
                Caption = 'Seating';
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(6150665),
                                      "No." = FIELD(Code);
                        ShortCutKey = 'Shift+Ctrl+D';
                        ApplicationArea=All;
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ApplicationArea=All;

                        trigger OnAction()
                        var
                            NPRESeating: Record "NPR NPRE Seating";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            //-NPR5.53 [380609]
                            CurrPage.SetSelectionFilter(NPRESeating);
                            DefaultDimMultiple.SetMultiRecord(NPRESeating, FieldNo(Code));
                            DefaultDimMultiple.RunModal;
                            //-NPR5.53 [380609]
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateCurrentWaiterPadDescription;
    end;
}

