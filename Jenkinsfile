// Jenkinsfile
pipeline {
    agent any  // Runs the pipeline on any available agent

    stages {
        stage('Install Dependencies') {
            steps {
                script {
                    // Install dependencies (change this according to your project)
                    sh 'pip install -r requirements.txt'  // Example for Python projects
                }
            }
        }
        stage('Run Tests') {
            steps {
                script {
                    // Run your tests (change this according to your testing framework)
                    sh 'python -m pytest'  // Example for Python tests
                }
            }
        }
        stage('Deploy') {
            when {
                // Only deploy if tests pass
                branch 'main'
            }
            steps {
                script {
                    // Deploy to your environment (change this according to your deployment process)
                    echo 'Deploying application...'
                    // sh 'your-deployment-command'  // Example deployment command
                }
            }
        }
    }

    post {
        always {
            // Cleanup or notification after the pipeline runs
            echo 'Pipeline finished!'
        }
        success {
            // Actions on success, like notifying a team or pushing changes
            echo 'Build succeeded!'
        }
        failure {
            // Actions on failure, like notifying a team or rolling back changes
            echo 'Build failed!'
        }
    }
}