xmlport 6014412 "Dankort Transaktion"
{
    // NPR5.39/TJ  /20180208 CASE 302634 Removed unused variables

    Caption = 'Dankot Transaction';

    schema
    {
        tableelement("Credit Card Transaction";"Credit Card Transaction")
        {
            XmlName = 'CreditCardTransaction';
        }
    }

    requestpage
    {
        Caption = 'Dankort Transaktion';

        layout
        {
        }

        actions
        {
        }
    }

    var
        Ekspedition: Record "Sale POS";

    procedure init(pEkspeditionslinie: Record "Sale Line POS")
    begin
        Ekspedition.SetRange("Register No.",pEkspeditionslinie."Register No.");
        Ekspedition.SetRange("Sales Ticket No.",pEkspeditionslinie."Sales Ticket No.");
        Ekspedition.SetRange("Saved Sale",false);
        Ekspedition.Find('+');
    end;
}

