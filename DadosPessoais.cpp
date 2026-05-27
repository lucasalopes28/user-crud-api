#include <iostream>
#include <string>
#include <regex>

class DadosPessoais {
private:
    std::string nomeCompleto;
    std::string cpf;
    std::string dataNascimento;

    // Valida formato CPF: 000.000.000-00
    bool validarCPF(const std::string& cpf) {
        std::regex formato(R"(\d{3}\.\d{3}\.\d{3}-\d{2})");
        return std::regex_match(cpf, formato);
    }

    // Valida formato data: DD/MM/AAAA
    bool validarData(const std::string& data) {
        std::regex formato(R"(\d{2}/\d{2}/\d{4})");
        return std::regex_match(data, formato);
    }

public:
    void coletarDados() {
        std::cout << "=== Cadastro de Dados Pessoais ===" << std::endl;

        std::cout << "\nNome completo: ";
        std::getline(std::cin, nomeCompleto);

        do {
            std::cout << "CPF (formato 000.000.000-00): ";
            std::getline(std::cin, cpf);
            if (!validarCPF(cpf))
                std::cout << "Formato invalido. Tente novamente." << std::endl;
        } while (!validarCPF(cpf));

        do {
            std::cout << "Data de nascimento (DD/MM/AAAA): ";
            std::getline(std::cin, dataNascimento);
            if (!validarData(dataNascimento))
                std::cout << "Formato invalido. Tente novamente." << std::endl;
        } while (!validarData(dataNascimento));
    }

    void exibirDados() const {
        std::cout << "\n=== Dados Informados ===" << std::endl;
        std::cout << "Nome completo   : " << nomeCompleto << std::endl;
        std::cout << "CPF             : " << cpf << std::endl;
        std::cout << "Data nascimento : " << dataNascimento << std::endl;
    }
};

int main() {
    DadosPessoais usuario;
    usuario.coletarDados();
    usuario.exibirDados();
    return 0;
}
