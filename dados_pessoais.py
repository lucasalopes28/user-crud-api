import re

class DadosPessoais:
    def __init__(self):
        self.nome_completo = ""
        self.cpf = ""
        self.data_nascimento = ""

    def _validar_cpf(self, cpf: str) -> bool:
        return bool(re.fullmatch(r"\d{3}\.\d{3}\.\d{3}-\d{2}", cpf))

    def _validar_data(self, data: str) -> bool:
        return bool(re.fullmatch(r"\d{2}/\d{2}/\d{4}", data))

    def coletar_dados(self):
        print("=== Cadastro de Dados Pessoais ===\n")

        self.nome_completo = input("Nome completo: ")

        while True:
            self.cpf = input("CPF (formato 000.000.000-00): ")
            if self._validar_cpf(self.cpf):
                break
            print("Formato inválido. Tente novamente.")

        while True:
            self.data_nascimento = input("Data de nascimento (DD/MM/AAAA): ")
            if self._validar_data(self.data_nascimento):
                break
            print("Formato inválido. Tente novamente.")

    def exibir_dados(self):
        print("\n=== Dados Informados ===")
        print(f"Nome completo   : {self.nome_completo}")
        print(f"CPF             : {self.cpf}")
        print(f"Data nascimento : {self.data_nascimento}")


if __name__ == "__main__":
    usuario = DadosPessoais()
    usuario.coletar_dados()
    usuario.exibir_dados()
