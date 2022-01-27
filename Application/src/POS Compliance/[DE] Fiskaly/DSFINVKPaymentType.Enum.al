enum 6014471 "NPR DSFINVK Payment Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;

    value(0; Bar) { Caption = 'Bar'; }
    value(1; Unbar) { Caption = 'Unbar'; }
    value(2; ECKarte) { Caption = 'ECKarte'; }
    value(3; Kreditkarte) { Caption = 'Kreditkarte'; }
    value(4; ElZahlungsdienstleister) { Caption = 'ElZahlungsdienstleister'; }
    value(5; GuthabenKarte) { Caption = 'GuthabenKarte'; }
    value(6; Keine) { Caption = 'Keine'; }
}
