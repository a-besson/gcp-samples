import os
import random
import time


def main():
    job_name = os.environ.get("CLOUD_RUN_JOB", "unknown")
    task_index = os.environ.get("CLOUD_RUN_TASK_INDEX", "0")
    task_count = os.environ.get("CLOUD_RUN_TASK_COUNT", "1")

    print(f"Starting Cloud Run Job: {job_name}")
    print(f"Task {task_index}/{task_count}")

    delay = random.randint(1, 5)
    print(f"Simulating work for {delay} seconds...")
    time.sleep(delay)

    print("Hello, World from Cloud Run Job!")
    print("Job completed successfully!")


if __name__ == "__main__":
    main()
