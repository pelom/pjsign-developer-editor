/**
 * Created by andreleite on 01/10/17.
 */
@IsTest
private class TorneioServicoTest {

	@IsTest
	static void testGetServico() {
		Torneio__c torneio = new Torneio__c();
		torneio.Titulo__c = 'Titulo';
		torneio.DataInicio__c = Datetime.now();
		torneio.DataFinal__c = Datetime.now();
		INSERT torneio;

		TorneioServico torneioServ = TorneioServico.getServico();
		List<TorneioEvento__c> eventos = torneioServ.obterEventos(torneio.Id);

		System.assertEquals(false, eventos.isEmpty(), 'Nenhum eventos encontrado');
	}

	@IsTest
	static void testObterEventos() {

	}
}