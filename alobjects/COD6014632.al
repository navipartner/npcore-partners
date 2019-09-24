codeunit 6014632 "Touch - Event Subscribers"
{
    // NPR5.23/LS  /20160616 CASE 226819  Modify function NewCustomer
    // NPR5.26/JDH/20160923  CASE 253243  Validate Customer No, to obtain Phone No lookup functionality

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        EventTarget: Option ,Item,Customer;
        Text001: Label 'Please Type the Customer No you wish to create';
        TextErrCust: Label 'This customer already exists';
        TextConfirmNewCustomer: Label 'This will create a new customer. Are you sure you want to continue?';

    procedure ConfigureCustomer()
    begin
        EventTarget := EventTarget::Customer;
    end;

    local procedure NewItem(var RecRef: RecordRef)
    var
        Item: Record Item;
        ItemCard: Page "Item Card";
        TextConfirmNewItem: Label 'This will create a new item. Are you sure you want to continue?';
    begin
        if not Confirm(TextConfirmNewItem) then
            exit;

        Item.Insert(true);
        Commit;
        ItemCard.SetRecord(Item);
        ItemCard.RunModal();
        RecRef.GetTable(Item);
    end;

    local procedure ItemCard(RecRef: RecordRef)
    var
        Item: Record Item;
        ItemCard: Page "Item Card";
    begin
        RecRef.SetTable(Item);
        ItemCard.SetRecord(Item);
        ItemCard.RunModal();
    end;

    local procedure NewCustomer(var RecRef: RecordRef)
    var
        Customer: Record Customer;
        CustCard: Page "Customer Card";
        IComm: Record "I-Comm";
        MasterNoInputDialog: Page "Master No. Input Dialog";
        CustomerNo: Code[20];
    begin
        //-NPR5.23 [226819]
        //IF NOT Marshaller.Confirm('',TextConfirmNewCustomer) THEN
        //EXIT;
        // Cust.INSERT(TRUE);
        // COMMIT;

        //CustCard.SETRECORD(Cust);
        //CustCard.RUNMODAL();
        //RecRef.GETTABLE(Cust);

        if IComm.Get and (IComm."Use Auto. Cust. Lookup") then begin
            IComm.TestField("Number Info Codeunit ID");
            Customer.Init;
            MasterNoInputDialog.SetInput(Customer."No.", Text001);
            MasterNoInputDialog.LookupMode(true);
            if MasterNoInputDialog.RunModal = ACTION::LookupOK then begin
                //-NPR5.26
                //MasterNoInputDialog.InputCode(Customer."No." )
                MasterNoInputDialog.InputCode(CustomerNo);
                Customer.Validate("No.", CustomerNo);
                //+NPR5.26
            end else
                exit;
            if Customer.Get(Customer."No.") then
                Error(TextErrCust);
        end;

        if (Customer."No." = '') then
            if not Confirm(TextConfirmNewCustomer) then
                exit;

        Customer.Insert(true);
        Commit;

        CustCard.SetRecord(Customer);
        CustCard.RunModal();
        RecRef.GetTable(Customer);
        //+NPR5.23 [226819]
    end;

    local procedure CustomerCard(RecRef: RecordRef)
    var
        Cust: Record Customer;
        CustCard: Page "Customer Card";
    begin
        RecRef.SetTable(Cust);
        CustCard.SetRecord(Cust);
        CustCard.RunModal();
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014631, 'OnLookupNew', '', false, false)]
    local procedure Lookup_OnNew(CardPageId: Integer; var RecRef: RecordRef)
    begin
        case EventTarget of
            EventTarget::Item:
                NewItem(RecRef);
            EventTarget::Customer:
                NewCustomer(RecRef);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014631, 'OnLookupShowCard', '', false, false)]
    local procedure Lookup_OnCard(CardPageId: Integer; RecRef: RecordRef)
    begin
        case EventTarget of
            EventTarget::Item:
                ItemCard(RecRef);
            EventTarget::Customer:
                CustomerCard(RecRef);
        end;
    end;
}

