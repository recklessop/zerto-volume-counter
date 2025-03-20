import json

def find_largest_recovery_volume(data):
    """
    Find the largest recovery volume in the given data.

    Args:
        data (list): List of JSON objects representing volumes.

    Returns:
        dict: The JSON object representing the largest recovery volume.
    """
    max_size = 0
    largest_recovery_volume = None

    for obj in data:
        if 'VolumeType' in obj and obj['VolumeType'] == 'Recovery':
            size_in_bytes = obj.get('Size', {}).get('ProvisionedInBytes')
            if size_in_bytes is not None and size_in_bytes > max_size:
                max_size = size_in_bytes
                largest_recovery_volume = obj

    return largest_recovery_volume

def calculate_average_recovery_size(data):
    """
    Calculate the average size of all recovery volumes in the given data.

    Args:
        data (list): List of JSON objects representing volumes.

    Returns:
        float: The average size of all recovery volumes in bytes.
    """
    total_size = 0
    num_recoveries = 0

    for obj in data:
        if 'VolumeType' in obj and obj['VolumeType'] == 'Recovery':
            size_in_bytes = obj.get('Size', {}).get('ProvisionedInBytes')
            if size_in_bytes is not None:
                total_size += size_in_bytes
                num_recoveries += 1

    if num_recoveries > 0:
        average_size = total_size / num_recoveries
    else:
        average_size = 0.0

    return average_size

def humanize_size(size_in_bytes):
    """
    Convert a size in bytes to a human-friendly string.

    Args:
        size_in_bytes (int): The size in bytes.

    Returns:
        str: A human-friendly string representation of the size.
    """
    if size_in_bytes < 1024:
        return f"{size_in_bytes} bytes"
    elif size_in_bytes < 1024 ** 2:
        return f"{size_in_bytes / 1024:.1f} KB"
    elif size_in_bytes < 1024 ** 3:
        return f"{size_in_bytes / (1024 ** 2):.1f} MB"
    else:
        return f"{size_in_bytes / (1024 ** 3):.1f} GB"

def main():
    # Load the JSON data from a file or some other source
    with open('data.json') as f:
        data = json.load(f)

    largest_recovery_volume = find_largest_recovery_volume(data)
    if largest_recovery_volume is not None:
        print("Largest Recovery Volume:")
        size_in_bytes = largest_recovery_volume.get('Size', {}).get('ProvisionedInBytes')
        if size_in_bytes is not None:
            size_string = humanize_size(size_in_bytes)
            print(f"Size: {size_in_bytes} ({size_string})")
    else:
        print("No recovery volumes found.")

    average_recovery_size = calculate_average_recovery_size(data)
    if average_recovery_size > 0.0:
        size_string = humanize_size(int(average_recovery_size))
        print(f"Average size of all recovery volumes: {size_string}")
    else:
        print("No recovery volumes found to calculate average size.")

if __name__ == "__main__":
    main()
