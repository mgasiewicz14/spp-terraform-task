import json
import boto3
import math

a = 1.40e-3
b = 2.37e-4
c = 9.90e-8

sns_client = boto3.client('sns')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('SensorStatus')
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:468017795964:Alerts" 

def temp_calculation(resistance):
    if resistance < 1 or resistance > 20000:
        return {"error": "VALUE OUT OF RANGE"}

    res = math.log(resistance)
    temp_k = 1 / (a + b * res + c * (res)**3)
    temp_c = temp_k - 273.15

    return {"temperature": temp_c}

def sns_notification(sensor_id, temperature):
    message = {
        "sensor_id": sensor_id,
        "temperature": temperature,
        "status": "TEMPERATURE_CRITICAL",
        "message": f"Sensor {sensor_id} detected CRITICAL temperature: {temperature:.2f}°C"
    }

    response = sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=json.dumps(message),
        Subject="CRITICAL TEMPERATURE ALERT"
    )

def sensor_status(sensor_id,broken):
    response = table.put_item(
        Item={
            'sensor_id': sensor_id,
            'broken': broken
        }
    )

def is_broken(sensor_id):
    response = table.get_item(Key={'sensor_id': sensor_id})
    return response.get('Item', {}).get('broken', False)


def lambda_handler(event, context):
    try:
        data = json.loads(event['body'])
        sensor_id = data.get("sensor_id")
        resistance = float(data.get("value", 0))

        if is_broken(sensor_id):
            return {
                'statusCode': 400,
                'body': json.dumps({"error": f"SENSOR {sensor_id} IS BROKEN"})
            }

        result = temp_calculation(resistance)
        result["sensor_id"] = sensor_id 

        if "error" in result:
            sensor_status(sensor_id, True)  
            return {
                'statusCode': 400,
                'body': json.dumps(result)
            }

        if result["temperature"] < 20:
            result["status"] = "TEMPERATURE_TOO_LOW"
            sensor_status(sensor_id, False)
        elif 20 <= result["temperature"] < 100:
            result["status"] = "OK"
            sensor_status(sensor_id, False)
        elif 100 <= result["temperature"] < 250:
            result["status"] = "TEMPERATURE_TOO_HIGH"
            sensor_status(sensor_id, False)
        else:
            result["status"] = "TEMPERATURE_CRITICAL"
            sns_notification(sensor_id, result["temperature"])
            sensor_status(sensor_id, True)

        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps({"error": str(e)})
        }