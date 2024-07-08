interface "NPR Rep. WS IFunctions"
{
    procedure GetLastReplicationCounter(TableId: Integer; ServiceSetup: Record "NPR Replication Service Setup"; Endpoint: Record "NPR Replication Endpoint"): BigInteger
}
