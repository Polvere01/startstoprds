import boto3
import datetime

def enable_aurora_cluster():
    # Configuração da região da AWS
    region = 'sa-east-1'

    # Configuração do identificador do cluster Aurora
    cluster_identifier = 'mysql-db-cluster'

    # Criação de uma instância do cliente do RDS
    rds_client = boto3.client('rds', region_name=region)

    # Habilita o cluster Aurora
    response = rds_client.start_db_cluster(
        DBClusterIdentifier=cluster_identifier
    )

    return {
        'statusCode': 200,
        'body': 'Cluster Aurora habilitado com sucesso.'
    }

def disable_aurora_cluster():
    # Configuração da região da AWS
    region = 'sa-east-1'

    # Configuração do identificador do cluster Aurora
    cluster_identifier = 'mysql-db-cluster'

    # Criação de uma instância do cliente do RDS
    rds_client = boto3.client('rds', region_name=region)

    # Desabilita o cluster Aurora
    response = rds_client.stop_db_cluster(
        DBClusterIdentifier=cluster_identifier
    )

    return {
        'statusCode': 200,
        'body': 'Cluster Aurora desabilitado com sucesso.'
    }

def lambda_handler(event, context):
    # Obtém o horário atual
    current_time = datetime.datetime.now().time()

    # Verifica se é 7 da manhã
    if current_time.hour == 10:
        return enable_aurora_cluster()

    # Verifica se é 20 horas da noite
    elif current_time.hour == 22:
        return disable_aurora_cluster()

    else:
        return {
            'statusCode': 200,
            'body': 'Ainda não é 7 da manhã nem 20 horas. O cluster Aurora não será modificado.'
        }
