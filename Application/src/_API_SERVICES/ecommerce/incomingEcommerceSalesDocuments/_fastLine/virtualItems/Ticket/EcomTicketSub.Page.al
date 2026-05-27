#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150947 "NPR Ecom Ticket Sub"
{
    Caption = 'Tickets';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR TM Ticket";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the internal ticket number.';
                }
                field("External Ticket No."; Rec."External Ticket No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the external ticket number presented to the customer.';
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ticket type.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item number this ticket was sold under.';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date from which the ticket is valid.';
                }
                field("Valid From Time"; Rec."Valid From Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the time from which the ticket is valid.';
                }
                field("Valid To Date"; Rec."Valid To Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date until which the ticket is valid.';
                }
                field("Valid To Time"; Rec."Valid To Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the time until which the ticket is valid.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenTicket)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected ticket to see full details.';

                trigger OnAction()
                var
                    EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
                begin
                    EcomCreateTicketImpl.OpenTicketCardForSystemId(Rec.SystemId);
                end;
            }
        }
    }

    /// <summary>
    /// Clears the temp buffer. Called by the parent page before enqueueing a background task
    /// or on task error.
    /// </summary>
    internal procedure ClearContents()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        CurrPage.Update(false);
    end;

    /// <summary>
    /// Populates the temp buffer from a JSON array payload produced by the parent's background
    /// task. Insert(false, true): preserve SystemId for the Open action.
    /// </summary>
    internal procedure PopulateFromJsonText(JsonText: Text)
    var
        TicketsJson: JsonArray;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if (JsonText <> '') and TicketsJson.ReadFrom(JsonText) then
            PopulateBufferFromJson(TicketsJson);
        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure PopulateBufferFromJson(TicketsJson: JsonArray)
    var
        TicketToken: JsonToken;
        TicketObj: JsonObject;
        FieldToken: JsonToken;
        ParsedSystemId: Guid;
    begin
        foreach TicketToken in TicketsJson do begin
            TicketObj := TicketToken.AsObject();
            Rec.Init();
            if TicketObj.Get('No', FieldToken) then
                Rec."No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."No."));
            if TicketObj.Get('Ext', FieldToken) then
                Rec."External Ticket No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."External Ticket No."));
            if TicketObj.Get('Type', FieldToken) then
                Rec."Ticket Type Code" := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Ticket Type Code"));
            if TicketObj.Get('Item', FieldToken) then
                Rec."Item No." := CopyStr(FieldToken.AsValue().AsText(), 1, MaxStrLen(Rec."Item No."));
            if TicketObj.Get('VFromD', FieldToken) then
                Rec."Valid From Date" := FieldToken.AsValue().AsDate();
            if TicketObj.Get('VFromT', FieldToken) then
                Rec."Valid From Time" := FieldToken.AsValue().AsTime();
            if TicketObj.Get('VToD', FieldToken) then
                Rec."Valid To Date" := FieldToken.AsValue().AsDate();
            if TicketObj.Get('VToT', FieldToken) then
                Rec."Valid To Time" := FieldToken.AsValue().AsTime();
            if TicketObj.Get('Sid', FieldToken) then
                if Evaluate(ParsedSystemId, FieldToken.AsValue().AsText()) then
                    Rec.SystemId := ParsedSystemId;
            Rec.Insert(false, true);
        end;
    end;
}
#endif
