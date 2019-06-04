package database_access_object;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import set_class.DapAnTracNghiem;
import set_class.TracNghiem;
import set_class.TuLuan;

/**
 * Class chứa các hàm để lấy giá trị từ cơ sở dữ liệu hoặc thêm, sửa, xóa dữ
 * liệu từ cơ sở dữ liệu
 * 
 * @author Hoàng Hải Đăng
 *
 */
public class DAO {
	private Connection conn;

	/**
	 * Tạo chuỗi kết nối vào cơ sở dữ liệu
	 */
	public DAO() {
		try {
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			conn = DriverManager
					.getConnection("jdbc:sqlserver://localhost:1433;databasename=FINAL_VER;integratedSecurity=true;");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Thêm một câu hỏi tự luận vào cơ sở dữ liệu
	 * 
	 * @param tuLuan Câu hỏi tự luận
	 * @throws SQLException SQLException
	 */
	public void themTuLuan(TuLuan tuLuan) throws SQLException {
		String query = "{call themMonHoc(?)}";
		CallableStatement cs = conn.prepareCall(query);
		cs.setString(1, tuLuan.getMonHoc());
		cs.executeUpdate();
		ArrayList<String> dsChuong = tuLuan.getChuong();
		for (String chuong : dsChuong) {
			query = "{call themChuong(?,?)}";
			cs = conn.prepareCall(query);
			cs.setString(1, chuong);
			cs.setString(2, tuLuan.getMonHoc());
			cs.executeUpdate();
		}
		query = "{call themTuLuan(?,?,?)}";
		cs = conn.prepareCall(query);
		cs.setString(1, tuLuan.getDeBai());
		cs.setString(2, tuLuan.getDoKho());
		cs.setString(3, tuLuan.getDapAn());
		cs.executeUpdate();
		for (String chuong : dsChuong) {
			query = "{call themTuLuanChuong(?)}";
			cs = conn.prepareCall(query);
			cs.setString(1, chuong);
			cs.executeUpdate();
		}
	}

	/**
	 * Thêm một câu hỏi trắc nghiệm vào cơ sở dữ liệu
	 * 
	 * @param tracNghiem Câu hỏi trắc nghiệm
	 * @throws SQLException SQLException
	 */
	public void themTracNghiem(TracNghiem tracNghiem) throws SQLException {
		String query = "{call themMonHoc(?)}";
		CallableStatement cs = conn.prepareCall(query);
		cs.setString(1, tracNghiem.getMonHoc());
		cs.executeUpdate();
		ArrayList<String> dsChuong = tracNghiem.getChuong();
		for (String chuong : dsChuong) {
			query = "{call themChuong(?,?)}";
			cs = conn.prepareCall(query);
			cs.setString(1, chuong);
			cs.setString(2, tracNghiem.getMonHoc());
			cs.executeUpdate();
		}
		query = "{call themTracNghiem(?,?)}";
		cs = conn.prepareCall(query);
		cs.setString(1, tracNghiem.getDeBai());
		cs.setString(2, tracNghiem.getDoKho());
		cs.executeUpdate();
		for (String chuong : dsChuong) {
			query = "{call themTracNghiemChuong(?)}";
			cs = conn.prepareCall(query);
			cs.setString(1, chuong);
			cs.executeUpdate();
		}
		ArrayList<DapAnTracNghiem> dsDapAn = tracNghiem.getDsDapAn();
		for (DapAnTracNghiem dapAnTracNghiem : dsDapAn) {
			query = "{call themTraLoiTracNghiem(?,?)}";
			cs = conn.prepareCall(query);
			cs.setString(1, dapAnTracNghiem.getDapAn());
			cs.setBoolean(2, dapAnTracNghiem.isDungSai());
			cs.executeUpdate();
		}
	}

	/**
	 * Lấy ra danh sách các câu hỏi tự luận
	 * 
	 * @return Danh sách câu hỏi tự luận
	 */
	public ArrayList<TuLuan> getDsTuLuan() {
		ArrayList<TuLuan> dsTuLuan = new ArrayList<TuLuan>();
		try {
			ArrayList<Integer> dsID = new ArrayList<Integer>();
			String query = "SELECT id FROM TuLuan";
			PreparedStatement ps = conn.prepareStatement(query);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				dsID.add(rs.getInt("id"));
			}
			for (int i = 0; i < dsID.size(); i++) {
				int id = dsID.get(i);
				TuLuan tuLuan = new TuLuan();
				tuLuan.setId(id + "");
				query = "SELECT deBai, doKho, dapAn FROM TuLuan WHERE id = " + id;
				ps = conn.prepareStatement(query);
				rs = ps.executeQuery();
				while (rs.next()) {
					tuLuan.setDeBai(rs.getString("deBai"));
					tuLuan.setDoKho(rs.getString("doKho"));
					tuLuan.setDapAn(rs.getString("dapAn"));
				}
				ArrayList<String> dsChuong = new ArrayList<String>();
				query = "SELECT Chuong.tenChuong FROM Chuong, TuLuanChuong WHERE Chuong.tenChuong = TuLuanChuong.tenChuong AND id = "
						+ id;
				ps = conn.prepareStatement(query);
				rs = ps.executeQuery();
				while (rs.next()) {
					dsChuong.add(rs.getString("tenChuong"));
				}
				tuLuan.setChuong(dsChuong);
				query = "SELECT DISTINCT tenMonHoc FROM Chuong, TuLuanChuong WHERE Chuong.tenChuong = TuLuanChuong.tenChuong AND id = "
						+ id;
				ps = conn.prepareStatement(query);
				rs = ps.executeQuery();
				while (rs.next()) {
					tuLuan.setMonHoc(rs.getString("tenMonHoc"));
				}
				dsTuLuan.add(tuLuan);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dsTuLuan;
	}

	/**
	 * Lấy ra ID của câu hỏi tự luận được thêm vào gần đây nhất
	 * 
	 * @return ID câu hỏi tự luận
	 */
	public String getLastIDTuLuan() {
		String query = "SELECT TOP 1 id FROM TuLuan ORDER BY id DESC";
		String lastIDTuLuan = "";
		try {
			PreparedStatement ps = conn.prepareStatement(query);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				lastIDTuLuan = rs.getInt("id") + "";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return lastIDTuLuan;
	}

	/**
	 * Lấy ra ID của câu hỏi trắc nghiệm được thêm vào gần đây nhất
	 * 
	 * @return ID câu hỏi trắc nghiệm
	 */
	public String getLastIDTracNghiem() {
		String query = "SELECT TOP 1 id FROM TracNghiem ORDER BY id DESC";
		String lastIDTracNghiem = "";
		try {
			PreparedStatement ps = conn.prepareStatement(query);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				lastIDTracNghiem = rs.getInt("id") + "";
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return lastIDTracNghiem;
	}

	/**
	 * Xóa một câu hỏi tự luận khỏi cơ sở dữ liệu
	 * 
	 * @param id ID của câu hỏi tự luận cần xóa
	 * @throws SQLException SQLException
	 */
	public void xoaTuLuan(int id) throws SQLException {
		String query = "{call xoaTuLuan(?)}";
		CallableStatement cs = conn.prepareCall(query);
		cs.setInt(1, id);
		cs.executeUpdate();

	}

	/**
	 * Xóa một câu hỏi trắc nghiệm khỏi cơ sở dữ liệu
	 * 
	 * @param id ID của câu hỏi trắc nghiệm cần xóa
	 * @throws SQLException SQLException
	 */
	public void xoaTracNghiem(int id) throws SQLException {
		String query = "{call xoaTracNghiem(?)}";
		CallableStatement cs = conn.prepareCall(query);
		cs.setInt(1, id);
		cs.executeUpdate();
	}

	/**
	 * Lấy ra danh sách các câu hỏi trắc nghiệm
	 * 
	 * @return Danh sách các câu hỏi trắc nghiệm
	 */
	public ArrayList<TracNghiem> getDsTracNghiem() {
		ArrayList<TracNghiem> dsTracNghiem = new ArrayList<TracNghiem>();
		try {
			ArrayList<Integer> dsID = new ArrayList<Integer>();
			String query = "SELECT id FROM TracNghiem";
			PreparedStatement ps = conn.prepareStatement(query);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				dsID.add(rs.getInt("id"));
			}
			for (int i = 0; i < dsID.size(); i++) {
				int id = dsID.get(i);
				TracNghiem tracNghiem = new TracNghiem();
				tracNghiem.setId(id + "");
				query = "SELECT deBai, doKho FROM TracNghiem WHERE id = " + id;
				ps = conn.prepareStatement(query);
				rs = ps.executeQuery();
				while (rs.next()) {
					tracNghiem.setDeBai(rs.getString("deBai"));
					tracNghiem.setDoKho(rs.getString("doKho"));
				}
				ArrayList<String> dsChuong = new ArrayList<String>();
				query = "SELECT Chuong.tenChuong FROM Chuong, TracNghiemChuong WHERE Chuong.tenChuong = TracNghiemChuong.tenChuong AND id = "
						+ id;
				ps = conn.prepareStatement(query);
				rs = ps.executeQuery();
				while (rs.next()) {
					dsChuong.add(rs.getString("tenChuong"));
				}
				tracNghiem.setChuong(dsChuong);
				query = "SELECT tenMonHoc FROM Chuong, TracNghiemChuong WHERE Chuong.tenChuong = TracNghiemChuong.tenChuong AND id = "
						+ id;
				ps = conn.prepareStatement(query);
				rs = ps.executeQuery();
				while (rs.next()) {
					tracNghiem.setMonHoc(rs.getString("tenMonHoc"));
				}
				ArrayList<DapAnTracNghiem> dsDapAn = new ArrayList<DapAnTracNghiem>();
				query = "SELECT dapAn, dungSai FROM TraLoiTracNghiem WHERE id = " + id;
				ps = conn.prepareStatement(query);
				rs = ps.executeQuery();
				while (rs.next()) {
					DapAnTracNghiem dapAnTracNghiem = new DapAnTracNghiem();
					dapAnTracNghiem.setDapAn(rs.getString("dapAn"));
					dapAnTracNghiem.setDungSai(rs.getBoolean("dungSai"));
					dsDapAn.add(dapAnTracNghiem);
				}
				tracNghiem.setDsDapAn(dsDapAn);
				dsTracNghiem.add(tracNghiem);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dsTracNghiem;
	}

	/**
	 * Lấy ra danh sách các môn học
	 * 
	 * @return Danh sách các môn học
	 * @throws SQLException SQLException
	 */
	public ArrayList<String> getDsMonHoc() throws SQLException {
		ArrayList<String> dsMonHoc = new ArrayList<String>();
		String query = "SELECT * FROM MonHoc";
		PreparedStatement ps = conn.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {
			dsMonHoc.add(rs.getString("tenMonHoc"));
		}
		return dsMonHoc;
	}

	/**
	 * Lấy ra danh sách các chương của một môn học
	 * 
	 * @param monHoc Môn học cần lấy ra các chương
	 * @return Danh sách chương của môn học
	 * @throws SQLException SQLException
	 */
	public ArrayList<String> getDsChuong(String monHoc) throws SQLException {
		ArrayList<String> dsChuong = new ArrayList<String>();
		String query = "SELECT tenChuong FROM Chuong WHERE tenMonHoc = N'" + monHoc + "'";
		PreparedStatement ps = conn.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {
			dsChuong.add(rs.getString("tenChuong"));
		}
		return dsChuong;
	}

	/**
	 * Lấy ra các câu hỏi thuộc một chương và độ khó cụ thể
	 * 
	 * @param tenChuong tên chương
	 * @param doKho     độ khó của câu hỏi cần lấy
	 * @return danh sách các câu hỏi chủa chương và độ khó
	 * @throws SQLException SQLException
	 */
	public ArrayList<String> getDsIDDoKho(String tenChuong, String doKho) throws SQLException {
		ArrayList<String> dsID = new ArrayList<String>();
		String query = "SELECT DISTINCT TracNghiem.id FROM TracNghiemChuong, TracNghiem WHERE TracNghiem.id = TracNghiemChuong.id AND tenChuong = N'"
				+ tenChuong + "' AND doKho = N'" + doKho + "'";
		PreparedStatement ps = conn.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {
			dsID.add(rs.getString("id"));
		}
		query = "SELECT DISTINCT TuLuan.id FROM TuLuanChuong, TuLuan WHERE TuLuan.id = TuLuanChuong.id AND tenChuong = N'"
				+ tenChuong + "' AND doKho = N'" + doKho + "'";
		rs = ps.executeQuery();
		while (rs.next()) {
			dsID.add(rs.getString("id"));
		}
		return dsID;
	}

	/**
	 * Lấy ra danh sách các câu hỏi thuộc một chương cụ thể
	 * 
	 * @param tenChuong tên chương
	 * @return danh sách các câu hỏi của chương
	 * @throws SQLException SQLException
	 */
	public ArrayList<String> getDsID(String tenChuong) throws SQLException {
		ArrayList<String> dsID = new ArrayList<String>();
		String query = "SELECT DISTINCT id FROM TracNghiemChuong WHERE tenChuong = N'" + tenChuong + "'";
		PreparedStatement ps = conn.prepareStatement(query);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {
			dsID.add(rs.getString("id"));
		}
		query = "SELECT DISTINCT id FROM TuLuanChuong WHERE tenChuong = N'" + tenChuong + "'";
		ps = conn.prepareStatement(query);
		rs = ps.executeQuery();
		while (rs.next()) {
			dsID.add(rs.getString("id"));
		}
		return dsID;
	}
}
