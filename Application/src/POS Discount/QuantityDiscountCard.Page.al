page 6014466 "NPR Quantity Discount Card"
{
    Caption = 'Multiple Price Header';
    SourceTable = "NPR Quantity Discount Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Main No."; "Main No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Main no. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modified Date field';
                }
                field("Block Custom Discount"; "Block Custom Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Custom Discount field';
                }
                field("Item Description"; "Item Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Description field';
                }
            }
            group(Conditions)
            {
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting date field';
                }
                field("Closing Date"; "Closing Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Date field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Closing Time"; "Closing Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closing Time field';
                }
                grid(Control6150629)
                {
                    ShowCaption = false;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
            }
            part(QuantityDiscountLine1; "NPR Quantity Discount Line")
            {
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Main no." = FIELD("Main No.");
                Visible = ActionVisible;
                Editable = DynamicEditable;
                Enabled = Rec."Main no." <> '';
                ApplicationArea = All;
            }
        }
        area(factboxes)
        {
            part(Control6150634; "Item Invoicing FactBox")
            {
                SubPageLink = "No." = FIELD("Item No.");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6014439),
                              "No." = FIELD("Main No.");
                ShortCutKey = 'Shift+Ctrl+D';
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';
            }
        }
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Function';
            }
            action(List)
            {
                Caption = 'List';
                Image = List;
                RunObject = Page "NPR Quantity Discount List";
                RunPageLink = "Item No." = field("Item No.");
                ApplicationArea = All;
                ToolTip = 'Executes the List action';
            }
            separator(Separator6150623)
            {
            }
            action("Send to Retail Journal")
            {
                Caption = 'Send to Retail Journal';
                Image = SendTo;
                ApplicationArea = All;
                ToolTip = 'Executes the Send to Retail Journal action';

                trigger OnAction()
                var
                    RetailJournalMgt: Codeunit "NPR Retail Journal Code";
                begin
                    RetailJournalMgt.Quantity2RetailJnl("Item No.", "Main No.", '');
                end;
            }
            action("Copy Multiple Price Discount")
            {
                Caption = 'Copy Multiple Price Discount';
                Image = CopyDocument;
                ApplicationArea = All;
                ToolTip = 'Executes the Copy Multiple Price Discount action';

                trigger OnAction()
                var
                    QuantityDiscountHeader: Record "NPR Quantity Discount Header";
                    QuantityDiscountLine1: Record "NPR Quantity Discount Line";
                    QuantityDiscountLine: Record "NPR Quantity Discount Line";
                begin
                    if PAGE.RunModal(PAGE::"NPR Quantity Discount List", QuantityDiscountHeader) <> ACTION::LookupOK then exit;
                    QuantityDiscountLine1.Reset;
                    QuantityDiscountLine1.SetRange("Main no.", "Main No.");
                    QuantityDiscountLine1.SetRange("Item No.", "Item No.");
                    QuantityDiscountLine1.DeleteAll;

                    QuantityDiscountLine1.Reset;
                    QuantityDiscountLine1.SetRange("Main no.", QuantityDiscountHeader."Main No.");
                    QuantityDiscountLine1.SetRange("Item No.", QuantityDiscountHeader."Item No.");
                    if QuantityDiscountLine1.FindSet then
                        repeat
                            QuantityDiscountLine.Init;
                            QuantityDiscountLine.TransferFields(QuantityDiscountLine1);
                            QuantityDiscountLine."Main no." := "Main No.";
                            QuantityDiscountLine."Item No." := "Item No.";
                            QuantityDiscountLine.Insert(true);
                        until QuantityDiscountLine1.Next = 0;

                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DynamicEditable := CurrPage.Editable;
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("Item No.", Rec.GetFilter("Item No."));
        if Rec.IsEmpty then begin
            Rec.Init();
            Rec."Main No." := Rec.GetFilter("Item No.");
            Rec.Insert(true);
        end;
        UpdateStatus();
        ActionVisible := true;
    end;

    var
        [InDataSet]
        ActionVisible: Boolean;
        DynamicEditable: Boolean;

    procedure UpdateStatus()
    var
        "Quantity Discount Header 2": Record "NPR Quantity Discount Header";
    begin
        "Quantity Discount Header 2".SetFilter(Status, '<>%1', Status::Balanced);
        if "Quantity Discount Header 2".FindFirst then
            repeat
                if ("Quantity Discount Header 2"."Closing Date" < Today) or
                   (("Quantity Discount Header 2"."Closing Date" = Today) and ("Quantity Discount Header 2"."Closing Time" < Time)) then begin
                    "Quantity Discount Header 2".Validate(Status, Status::Balanced);
                    "Quantity Discount Header 2".Modify(true);
                end;
            until "Quantity Discount Header 2".Next = 0;
    end;
}

