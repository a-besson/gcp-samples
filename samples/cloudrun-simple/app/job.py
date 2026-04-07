import os
import random
import time


def main():
    print("Starting Cloud Run Job...")
    print(f"Job Name: {os.environ.get('CLOUD_RUN_JOB', 'unknown')}")
    print(
        f"Task Index: {os.environ.get('CLOUD_RUN_TASK_INDEX', '0')}"
        f"/{os.environ.get('CLOUD_RUN_TASK_COUNT', '1')}"
    )

    delay = random.randint(1, 5)
    print(f"Simulating work for {delay} seconds...")
    time.sleep(delay)

    print("Job completed successfully!")


if __name__ == "__main__":
    main()
