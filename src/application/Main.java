/**
 * @author Hoang Hai Dang
 * Class chua ham main
 */
package application;
	
import java.sql.SQLException;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.layout.BorderPane;


public class Main extends Application {
	@Override
	public void start(Stage primaryStage) {
		try {
			BorderPane root = FXMLLoader.load(getClass().getResource("/fxml_file/XemTuLuan.fxml"));
			primaryStage.setResizable(false);
			Scene scene = new Scene(root);
			primaryStage.setScene(scene);
			primaryStage.setTitle("Câu hỏi tự luận");
			primaryStage.getIcons().add(new Image("/icon/iconWindows.png"));
			primaryStage.show();
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	public static void main(String[] args) throws SQLException {
		launch(args);
		
	}
}
